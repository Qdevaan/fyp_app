"""
Session routes — start, save, end, wingman transcript processing.
"""

import asyncio
import json
from datetime import datetime
from typing import Dict, List

from fastapi import APIRouter, Request
from starlette.responses import StreamingResponse

from app.models.requests import (
    StartSessionRequest,
    SaveSessionRequest,
    EndSessionRequest,
    WingmanRequest,
)
from app.services import graph_svc, vector_svc, brain_svc, session_svc, entity_svc
from app.utils.rate_limit import limiter
from app.utils.text_sanitizer import sanitize_input

router = APIRouter()

# ── In-memory state ───────────────────────────────────────────────────────────
LIVE_SESSIONS: Dict[str, str] = {}       # user_id → session_id
SESSION_TIMESTAMPS: Dict[str, datetime] = {}
SESSION_METADATA: Dict[str, dict] = {}   # session_id → {is_ephemeral, persona, ...}
TURN_COUNTERS: Dict[str, int] = {}
_MAX_GLOBAL_SESSIONS = 500
_SESSION_TTL_HOURS = 6


# ── Helpers ───────────────────────────────────────────────────────────────────

def _evict_if_over_capacity():
    if len(SESSION_TIMESTAMPS) > _MAX_GLOBAL_SESSIONS:
        sorted_sessions = sorted(SESSION_TIMESTAMPS.items(), key=lambda x: x[1])
        to_remove = len(SESSION_TIMESTAMPS) - _MAX_GLOBAL_SESSIONS
        for sid, _ in sorted_sessions[:to_remove]:
            SESSION_TIMESTAMPS.pop(sid, None)
            TURN_COUNTERS.pop(sid, None)
            SESSION_METADATA.pop(sid, None)
            for k, v in list(LIVE_SESSIONS.items()):
                if v == sid:
                    del LIVE_SESSIONS[k]
        print(f"🧹 Evicted {to_remove} oldest session(s) from global state")


# ══════════════════════════════════════════════════════════════════════════════
# POST /start_session
# ══════════════════════════════════════════════════════════════════════════════

@router.post("/start_session")
@limiter.limit("10/minute")
async def start_session_endpoint(request: Request, req: StartSessionRequest):
    """Create a new session and return its ID."""
    session_id = session_svc.start_session(
        req.user_id,
        mode=req.mode,
        is_ephemeral=req.is_ephemeral,
        is_multiplayer=req.is_multiplayer,
        persona=req.persona,
    )

    LIVE_SESSIONS[req.user_id] = session_id
    SESSION_TIMESTAMPS[session_id] = datetime.now()
    SESSION_METADATA[session_id] = {
        "is_ephemeral": req.is_ephemeral,
        "is_multiplayer": req.is_multiplayer,
        "persona": req.persona,
    }
    if req.target_entity_id is not None:
        SESSION_METADATA[session_id]["target_entity_id"] = req.target_entity_id

    _evict_if_over_capacity()
    return {"session_id": session_id}


# ══════════════════════════════════════════════════════════════════════════════
# POST /process_transcript_wingman
# ══════════════════════════════════════════════════════════════════════════════

@router.post("/process_transcript_wingman")
@limiter.limit("30/minute")
async def process_transcript_wingman(request: Request, req: WingmanRequest):
    """
    Real-time wingman: log turn, generate advice, extract entities,
    detect conflicts, extract events, save to memory.
    """
    user_id = req.user_id
    transcript = sanitize_input(req.transcript)
    session_id = req.session_id
    speaker_role = req.speaker_role if req.speaker_role in ("user", "others") else "others"

    is_ephemeral = SESSION_METADATA.get(session_id, {}).get("is_ephemeral", False)

    # 0. Log incoming transcript
    if session_id:
        session_svc.log_message(
            session_id, speaker_role, transcript,
            speaker_label=req.speaker_label, is_ephemeral=is_ephemeral,
        )

    # 1. Load contexts in parallel
    def _graph_ctx():
        graph_svc.load_graph(user_id)
        return graph_svc.find_context(user_id, transcript)

    target_entity_id = (
        SESSION_METADATA.get(session_id, {}).get("target_entity_id") if session_id else None
    )

    def _entity_ctx():
        if target_entity_id:
            return entity_svc.get_entity_context(user_id, str(target_entity_id))
        return ""

    g_ctx, v_ctx, e_ctx = await asyncio.gather(
        asyncio.to_thread(_graph_ctx),
        asyncio.to_thread(vector_svc.search_memory, user_id, transcript),
        asyncio.to_thread(_entity_ctx),
    )

    if e_ctx:
        g_ctx = f"ROLEPLAY TARGET ENTITY CONTEXT:\n{e_ctx}\n\n" + g_ctx

    # 2. Get advice (only for 'others' speech)
    advice = "WAITING"
    if speaker_role == "others":
        advice = brain_svc.get_wingman_advice(
            user_id, transcript, g_ctx, v_ctx, req.mode, req.persona,
        )

    # 3. Log LLM advice
    if session_id and advice and advice != "WAITING":
        session_svc.log_message(session_id, "llm", advice, is_ephemeral=is_ephemeral)

    # 4. Extract entities
    extraction = brain_svc.extract_entities_full(transcript)
    new_rels = extraction.get("relations", [])
    if extraction.get("entities"):
        await asyncio.to_thread(
            entity_svc.persist_extraction, user_id, extraction, session_id,
        )

    # 5. Update graph + detect conflicts
    if new_rels:
        graph_svc.update_local_graph(user_id, new_rels)
        conflicts = brain_svc.detect_conflicts(new_rels, g_ctx)
        if conflicts:
            await asyncio.to_thread(entity_svc.save_conflicts, user_id, conflicts, session_id)
    graph_svc.save_graph(user_id)

    # 6. Extract events
    events = brain_svc.extract_events(transcript)
    if events:
        await asyncio.to_thread(entity_svc.save_events, user_id, events, session_id)

    # 7. Save to long-term memory
    await vector_svc.save_memory(user_id, f"{speaker_role.capitalize()}: {transcript}")

    # 8. Rolling summarization every 20 turns
    if session_id:
        TURN_COUNTERS[session_id] = TURN_COUNTERS.get(session_id, 0) + 1
        if TURN_COUNTERS[session_id] % 20 == 0:
            _sid = session_id
            _turn = TURN_COUNTERS[session_id]

            async def _rolling_summarize():
                from app.database import db as _db
                try:
                    logs_res = (
                        _db.table("session_logs")
                        .select("role, content")
                        .eq("session_id", _sid)
                        .order("created_at")
                        .execute()
                    )
                    recent_rows = (logs_res.data or [])[-40:]
                    partial_transcript = "\n".join(
                        f"{r['role'].upper()}: {r['content']}" for r in recent_rows
                    )
                    if partial_transcript:
                        rolling_summary = brain_svc.generate_summary(partial_transcript)
                        if rolling_summary:
                            prev_res = (
                                _db.table("sessions")
                                .select("summary")
                                .eq("id", _sid)
                                .execute()
                            )
                            prev_summary = ""
                            if prev_res.data and prev_res.data[0].get("summary"):
                                prev_summary = prev_res.data[0]["summary"]
                            combined = (
                                f"{prev_summary}\n---\n[Turn {_turn}] {rolling_summary}"
                            ).strip()
                            _db.table("sessions").update({"summary": combined}).eq(
                                "id", _sid
                            ).execute()
                            print(f"🔄 Rolling summary appended at turn {_turn}")
                except Exception as e:
                    print(f"❌ Rolling summarize error: {e}")

            asyncio.create_task(_rolling_summarize())

    return {"advice": advice}


# ══════════════════════════════════════════════════════════════════════════════
# POST /save_session
# ══════════════════════════════════════════════════════════════════════════════

@router.post("/save_session")
@limiter.limit("10/minute")
async def save_session_endpoint(request: Request, req: SaveSessionRequest):
    """Save a completed session (no prior LIVE_SESSIONS entry)."""
    if req.is_ephemeral:
        return {"status": "success", "session_id": "ephemeral-skipped"}

    user_id = req.user_id
    transcript = req.transcript
    logs = req.logs

    # 1. Create session record
    session_id = session_svc.create_session_record(
        user_id,
        title=f"Live Session {datetime.now().strftime('%Y-%m-%d %H:%M')}",
        mode="live_wingman",
    )

    # 2. Bulk-log turns
    session_svc.log_batch_messages(session_id, logs)

    # 3. Extract entities
    extraction = brain_svc.extract_entities_full(transcript)
    new_rels = extraction.get("relations", [])
    if extraction.get("entities"):
        await asyncio.to_thread(
            entity_svc.persist_extraction, user_id, extraction, session_id,
        )

    # 4. Extract events
    events = brain_svc.extract_events(transcript)
    if events:
        await asyncio.to_thread(entity_svc.save_events, user_id, events, session_id)

    # 5. Update knowledge graph
    if new_rels:
        graph_svc.load_graph(user_id)
        graph_svc.update_local_graph(user_id, new_rels)
        graph_svc.save_graph(user_id)

    # 6. Generate summary and mark completed
    summary = brain_svc.generate_summary(transcript)
    session_svc.end_session(session_id, summary=summary or None)

    # 7. Save to long-term memory
    mem_content = (
        f"Session Summary: {summary}" if summary
        else f"Session Transcript: {transcript[:1000]}"
    )
    await vector_svc.save_memory(user_id, mem_content)

    return {"status": "success", "session_id": session_id}


# ══════════════════════════════════════════════════════════════════════════════
# POST /end_session
# ══════════════════════════════════════════════════════════════════════════════

@router.post("/end_session")
@limiter.limit("10/minute")
async def end_session_endpoint(request: Request, req: EndSessionRequest):
    """End an active session: summarize, mark completed, compute analytics."""
    from app.routes.analytics import _compute_session_analytics
    from app.database import db as _db

    try:
        is_ephemeral = SESSION_METADATA.get(req.session_id, {}).get("is_ephemeral", False)

        if is_ephemeral:
            session_svc.end_session(req.session_id, is_ephemeral=True)
        else:
            logs_res = (
                _db.table("session_logs")
                .select("role, content")
                .eq("session_id", req.session_id)
                .order("created_at")
                .execute()
            )
            full_transcript = "\n".join(
                f"{r['role'].upper()}: {r['content']}"
                for r in (logs_res.data or [])
            )
            summary = (
                brain_svc.generate_summary(full_transcript) if full_transcript else ""
            )
            session_svc.end_session(req.session_id, summary=summary or None)

            if full_transcript:
                mem_content = (
                    f"Session Summary: {summary}" if summary
                    else full_transcript[:500]
                )
                await vector_svc.save_memory(req.user_id, mem_content)

        # Clean up in-memory state
        for k, v in list(LIVE_SESSIONS.items()):
            if v == req.session_id:
                del LIVE_SESSIONS[k]
        TURN_COUNTERS.pop(req.session_id, None)
        SESSION_TIMESTAMPS.pop(req.session_id, None)
        SESSION_METADATA.pop(req.session_id, None)
    except Exception as e:
        print(f"❌ end_session error: {e}")
        session_svc.end_session(req.session_id)

    # Fire analytics in background
    asyncio.create_task(_compute_session_analytics(req.session_id, req.user_id))

    return {"status": "completed", "session_id": req.session_id}
