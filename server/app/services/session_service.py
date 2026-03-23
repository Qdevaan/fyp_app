"""
SessionService — session lifecycle, turn logging, consultant history.
Uses the unified db_final schema (sessions, session_logs, consultant_logs, sentiment_logs).
"""

import uuid
from datetime import datetime
from typing import Dict, List, Optional, Any

from app.database import db


class SessionService:
    """Creates sessions, logs turns, fetches history."""

    def __init__(self):
        print("✅ Session Service: Initialized")

    # ── Session Creation ──────────────────────────────────────────────────────

    def start_session(
        self,
        user_id: str,
        mode: str = "live_wingman",
        is_ephemeral: bool = False,
        is_multiplayer: bool = False,
        persona: str = "casual",
    ) -> str:
        """Create a new session row and return its UUID."""
        if not db:
            return str(uuid.uuid4())

        # Ephemeral (incognito) sessions bypass DB entirely
        if is_ephemeral:
            session_id = str(uuid.uuid4())
            print(
                f"🕵️ Session Service: Started INCOGNITO session {session_id} "
                f"for user {user_id} (mode={mode}, persona={persona})"
            )
            return session_id

        try:
            result = (
                db.table("sessions")
                .insert(
                    {
                        "user_id": user_id,
                        "title": "Live Wingman Session",
                        "session_type": mode,
                        "mode": mode,
                        "status": "active",
                        "is_ephemeral": is_ephemeral,
                        "is_multiplayer": is_multiplayer,
                        "persona": persona,
                    }
                )
                .execute()
            )
            session_id = result.data[0]["id"]
            print(
                f"📝 Session Service: Started session {session_id} "
                f"for user {user_id} (mode={mode})"
            )
            return session_id
        except Exception as e:
            print(f"❌ Session Service Error starting session: {e}")
            return str(uuid.uuid4())

    def create_session_record(
        self,
        user_id: str,
        title: str = "New Conversation",
        summary: str = None,
        mode: str = "live_wingman",
    ) -> str:
        """Create a session record and return its ID."""
        if not db:
            return str(uuid.uuid4())
        try:
            data = {
                "user_id": user_id,
                "title": title,
                "session_type": mode,
                "mode": mode,
                "status": "active",
            }
            if summary:
                data["summary"] = summary
            result = db.table("sessions").insert(data).execute()
            if result.data:
                return result.data[0]["id"]
            return str(uuid.uuid4())
        except Exception as e:
            print(f"❌ Session Service Error creating session: {e}")
            return str(uuid.uuid4())

    # ── Turn Logging ──────────────────────────────────────────────────────────

    def log_message(
        self,
        session_id: str,
        role: str,
        content: str,
        speaker_label: str = None,
        confidence: float = None,
        is_ephemeral: bool = False,
    ) -> Optional[Dict[str, Any]]:
        """Log a single message to session_logs with inline sentiment."""
        if not db or not session_id or not content.strip():
            return None
        if is_ephemeral:
            return None

        try:
            # ── Inline sentiment analysis ─────────────────────────────────
            sentiment_score = 0.0
            sentiment_label = "neutral"

            lower_content = content.lower()
            positive_words = [
                "great", "awesome", "good", "happy", "love",
                "excited", "amazing", "perfect", "thanks", "glad",
            ]
            negative_words = [
                "bad", "angry", "hate", "terrible", "sad",
                "frustrated", "annoyed", "worst", "failed", "mad",
            ]

            pos_count = sum(lower_content.count(w) for w in positive_words)
            neg_count = sum(lower_content.count(w) for w in negative_words)

            if pos_count > neg_count:
                sentiment_score = min(0.4 * pos_count, 1.0)
                sentiment_label = "positive"
            elif neg_count > pos_count:
                sentiment_score = max(-0.4 * neg_count, -1.0)
                sentiment_label = "negative"

            # Stress & arousal inference
            fillers = [" um", " uh", " like", " literally", " you know"]
            filler_count = sum(lower_content.count(f) for f in fillers)
            arousal = content.count("!") + content.count("?")
            hesitation = content.count("-") + content.count("...")
            stress_level = min(
                (filler_count * 0.2) + (arousal * 0.1) + (hesitation * 0.2), 1.0
            )
            if stress_level > 0.5:
                sentiment_label += "_stressed"
            elif stress_level > 0.2:
                sentiment_label += "_tense"

            # ── Insert session_log row ────────────────────────────────────
            row = {
                "session_id": session_id,
                "role": role,
                "content": content.strip(),
                "sentiment_score": sentiment_score,
                "sentiment_label": sentiment_label,
            }
            if speaker_label:
                row["speaker_label"] = speaker_label
            if confidence is not None:
                row["confidence"] = confidence

            res = db.table("session_logs").insert(row).execute()
            logged_row = res.data[0] if res.data else row

            # ── Write to sentiment_logs ───────────────────────────────────
            try:
                sess_res = (
                    db.table("sessions")
                    .select("user_id")
                    .eq("id", session_id)
                    .maybe_single()
                    .execute()
                )
                user_id = sess_res.data["user_id"] if sess_res.data else None
            except Exception:
                user_id = None

            if user_id and role in ["user", "others", "llm"]:
                logs_res = (
                    db.table("session_logs")
                    .select("id", count="exact")
                    .eq("session_id", session_id)
                    .execute()
                )
                turn_idx = logs_res.count or 1

                sent_row = {
                    "session_id": session_id,
                    "user_id": user_id,
                    "turn_index": turn_idx,
                    "speaker_role": role,
                    "sentiment_score": sentiment_score,
                    "score": sentiment_score,
                    "label": sentiment_label,
                }
                db.table("sentiment_logs").insert(sent_row).execute()

            return logged_row
        except Exception as e:
            print(f"❌ Session Service Error logging message: {e}")
            return None

    def log_batch_messages(
        self, session_id: str, logs: List[Dict[str, Any]], is_ephemeral: bool = False
    ):
        """Log a batch of messages to session_logs."""
        if not db or not logs or is_ephemeral:
            return
        try:
            db_logs = []
            for log in logs:
                role = log.get("speaker", "unknown").lower()
                content = log.get("text", "")
                if content:
                    db_logs.append(
                        {
                            "session_id": session_id,
                            "role": role,
                            "content": content,
                        }
                    )
            if db_logs:
                db.table("session_logs").insert(db_logs).execute()
                print(
                    f"📝 Session Service: Logged {len(db_logs)} messages "
                    f"for session {session_id}"
                )
        except Exception as e:
            print(f"❌ Session Service Error logging batch: {e}")

    # ── Session Completion ────────────────────────────────────────────────────

    def end_session(self, session_id: str, summary: str = None, is_ephemeral: bool = False):
        """Mark session as completed."""
        if not db or not session_id:
            return
        if is_ephemeral:
            print(f"🕵️ Session Service: Ephemeral session {session_id} ended")
            return
        try:
            update = {
                "status": "completed",
                "ended_at": datetime.now().isoformat(),
                "end_time": datetime.now().isoformat(),
            }
            if summary:
                update["summary"] = summary
            db.table("sessions").update(update).eq("id", session_id).execute()
            print(f"✅ Session Service: Session {session_id} marked completed")
        except Exception as e:
            print(f"❌ Session Service Error ending session: {e}")

    # ── Consultant History ────────────────────────────────────────────────────

    def log_consultant_qa(
        self, user_id: str, question: str, answer: str, session_id: str = None,
        is_ephemeral: bool = False,
    ):
        """Log Q&A to consultant_logs and session_logs."""
        if not db or is_ephemeral:
            return
        try:
            db.table("consultant_logs").insert(
                {
                    "user_id": user_id,
                    "question": question,
                    "answer": answer,
                    "query": question,
                    "response": answer,
                    "session_id": session_id,
                }
            ).execute()
            if session_id:
                self.log_message(session_id, "user", question)
                self.log_message(session_id, "llm", answer)
            print(f"📝 Session Service: Logged consultant Q&A for {user_id}")
        except Exception as e:
            print(f"❌ Session Service Error logging consultant Q&A: {e}")

    def fetch_consultant_history(self, user_id: str, limit: int = 5) -> str:
        """Fetch recent Q&A pairs from consultant_logs."""
        if not db:
            return "No past consultant history."
        try:
            res = (
                db.table("consultant_logs")
                .select("question, answer")
                .eq("user_id", user_id)
                .order("created_at", desc=True)
                .limit(limit)
                .execute()
            )
            history_lines = []
            for item in reversed(res.data):
                history_lines.append(f"Q: {item['question']}")
                history_lines.append(f"A: {item['answer']}")
            history_str = "\n".join(history_lines)
            return history_str if history_str else "No past consultant history."
        except Exception as e:
            print(f"❌ Session Service Error fetching consultant history: {e}")
            return "Error fetching past consultant history."

    def fetch_session_summaries(self, user_id: str, limit: int = 3) -> str:
        """Fetch recent completed session summaries."""
        if not db:
            return "No previous session summaries."
        try:
            res = (
                db.table("sessions")
                .select("title, summary, mode, created_at")
                .eq("user_id", user_id)
                .eq("status", "completed")
                .not_.is_("summary", "null")
                .order("created_at", desc=True)
                .limit(limit)
                .execute()
            )
            if not res.data:
                return "No previous session summaries."
            lines = []
            for s in reversed(res.data):
                mode_tag = s.get("mode", "session").upper()
                title = s.get("title", "Session")
                summary = s.get("summary", "")
                if summary:
                    lines.append(f"[{mode_tag}] {title}: {summary}")
            return "\n".join(lines) if lines else "No previous session summaries."
        except Exception as e:
            print(f"❌ Session Service Error fetching summaries: {e}")
            return "No previous session summaries."

    def count_session_turns(self, session_id: str) -> int:
        """Return the number of turns logged for a session."""
        if not db or not session_id:
            return 0
        try:
            res = (
                db.table("session_logs")
                .select("id", count="exact")
                .eq("session_id", session_id)
                .execute()
            )
            return res.count or 0
        except Exception as e:
            print(f"❌ Session Service Error counting turns: {e}")
            return 0
