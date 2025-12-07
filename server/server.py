
# ==========================================
# SECTION 1: IMPORTS & DEPENDENCIES
# ==========================================

import os
import json
import asyncio
import uvicorn
import networkx as nx
import qrcode
import httpx
import nest_asyncio
import uuid
from typing import List, Dict, Optional, Any
from datetime import datetime

# FastAPI & Server
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from pyngrok import ngrok

# AI & DB
from groq import Groq
from supabase import create_client, Client
from supabase.lib.client_options import ClientOptions

# FIX: Import torch explicitly BEFORE sentence_transformers
import torch
from sentence_transformers import SentenceTransformer

# LiveKit (VERSION 0.7.2 COMPATIBLE IMPORTS)
from livekit import api
from livekit.plugins import deepgram
from livekit.agents import AutoSubscribe, JobContext, Worker, WorkerOptions, JobRequest

# Fix for Colab/Jupyter event loops
nest_asyncio.apply()


# ==========================================
# SECTION 2: KEYS & CONFIGURATION
# ==========================================

class Settings:
    # --- API KEYS ---
    # DEEPGRAM: Speech-to-Text
    DEEPGRAM_KEY: str = os.getenv("DEEPGRAM_KEY", "")

    # LIVEKIT: Real-time Audio/Video
    LIVEKIT_URL: str = os.getenv("LIVEKIT_URL", "")
    LIVEKIT_API_KEY: str = os.getenv("LIVEKIT_API_KEY", "")
    LIVEKIT_API_SECRET: str = os.getenv("LIVEKIT_API_SECRET", "")

    # GROQ: LLM Inference
    GROQ_KEY: str = os.getenv("GROQ_API_KEY", "")

    # NGROK: Public Tunneling
    NGROK_TOKEN: str = os.getenv("NGROK_TOKEN", "")

    # SUPABASE: Database & Vectors
    SUPABASE_URL: str = os.getenv("SUPABASE_URL", "")
    SUPABASE_KEY: str = os.getenv("SUPABASE_KEY", "")

    # AI Models
    EMBEDDING_MODEL: str = "all-MiniLM-L6-v2"

    # LLM Models
    CONSULTANT_MODEL: str = "llama-3.3-70b-versatile" # Detailed, accurate, slower
    WINGMAN_MODEL: str = "llama-3.1-8b-instant" # Fast, low-latency for real-time

    # Server Settings
    HOST: str = "0.0.0.0"
    PORT: int = 8000

settings = Settings()

# Set Env Vars for LiveKit SDK to pick up automatically
os.environ['LIVEKIT_URL'] = settings.LIVEKIT_URL
os.environ['LIVEKIT_API_KEY'] = settings.LIVEKIT_API_KEY
os.environ['LIVEKIT_API_SECRET'] = settings.LIVEKIT_API_SECRET

# Global storage for live sessions (mapping user_id/room_name to session_id)
LIVE_SESSIONS: Dict[str, str] = {}


# ==========================================
# SECTION 3: MAIN SERVICES & LOGIC
# ==========================================

# --- 3A. Intelligence Services (Graph, Vector, Brain) ---

class GraphService:
    """Manages specific Knowledge Graphs for EACH connected user."""
    def __init__(self):
        self.active_graphs: Dict[str, nx.Graph] = {}
        try:
            options = ClientOptions(postgrest_client_timeout=10)
            options.storage = None # Ensure storage attribute exists
            options.httpx_client = None # Ensure httpx_client attribute exists
            self.supabase: Client = create_client(settings.SUPABASE_URL, settings.SUPABASE_KEY, options=options)
            print("✅ Graph Service: DB Connected")
        except Exception as e:
            print(f"⚠️ Graph Service Error: {e}")
            self.supabase = None

    def load_graph(self, user_id: str):
        if not self.supabase: return
        try:
            # Note: Assuming user_id is the primary key and TEXT type in DB
            response = self.supabase.table("knowledge_graphs").select("graph_data").eq("user_id", user_id).execute()
            if response.data and response.data[0]['graph_data']:
                data = response.data[0]['graph_data']
                self.active_graphs[user_id] = nx.node_link_graph(data)
                print(f"✅ Graph Service: Loaded {len(self.active_graphs[user_id].nodes)} nodes for {user_id}")
            else:
                self.active_graphs[user_id] = nx.Graph()
                print(f"🆕 Graph Service: New empty graph created for {user_id}")
        except Exception as e:
            print(f"❌ Graph Service Error loading graph for {user_id}: {e}")
            self.active_graphs[user_id] = nx.Graph()

    def save_graph(self, user_id: str):
        if user_id not in self.active_graphs or not self.supabase: return
        try:
            graph_json = nx.node_link_data(self.active_graphs[user_id])
            data = {
                "user_id": user_id,
                "graph_data": graph_json,
                "updated_at": datetime.now().isoformat()
            }
            # UPSERT handles creation or update
            self.supabase.table("knowledge_graphs").upsert(data).execute()
            print(f"✅ Graph Service: Saved graph for {user_id}")
            # Clean up local graph after saving
            del self.active_graphs[user_id]
        except Exception as e:
            print(f"❌ Graph Service Error saving graph for {user_id}: {e}")

    def find_context(self, user_id: str, text: str, top_k: int = 5) -> str:
        """Finds relevant facts from the in-memory graph."""
        if user_id not in self.active_graphs:
            return "No known graph facts."
        G = self.active_graphs[user_id]
        text_lower = text.lower()
        facts = []
        nodes_found = set()

        # Simple keyword matching for graph nodes
        for node in G.nodes():
            if str(node).lower() in text_lower or text_lower in str(node).lower():
                nodes_found.add(node)

        # Collect facts related to the found nodes
        for u, v, data in G.edges(data=True):
            if u in nodes_found or v in nodes_found:
                rel = data.get('relation', 'related to')
                facts.append(f"Fact: {u} {rel} {v}")

        context_str = "\n".join(list(set(facts)))
        return context_str if context_str else "No known graph facts."

    def update_local_graph(self, user_id: str, updates: List[dict]):
        """Updates the in-memory graph with new relationships."""
        if user_id not in self.active_graphs:
            print(f"⚠️ Graph Service: No active graph for {user_id} to update.")
            return
        if updates:
            print(f"➕ Graph Service: Updating graph for {user_id} with {len(updates)} new relationships.")
        for u in updates:
            source = u.get('source')
            target = u.get('target')
            relation = u.get('relation', 'related')
            if source and target:
                self.active_graphs[user_id].add_edge(source, target, relation=relation)
                # print(f"   Added edge: {source} - {relation} - {target}")


class VectorService:
    """Long-Term Memory (Supabase Vector Store)"""
    def __init__(self):
        print("🧠 Vector Service: Loading Embedding Model (MiniLM)...")
        self.model = SentenceTransformer(settings.EMBEDDING_MODEL)
        options = ClientOptions(postgrest_client_timeout=10)
        options.storage = None # Ensure storage attribute exists
        options.httpx_client = None # Ensure httpx_client attribute exists
        self.supabase: Client = create_client(settings.SUPABASE_URL, settings.SUPABASE_KEY, options=options)
        print("✅ Vector Service: Embedding Model Loaded & DB Connected")

    def search_memory(self, user_id: str, query: str) -> str:
        """Searches long-term memory via vector similarity."""
        if not self.supabase: return "No relevant past memories."
        try:
            # Search logic remains the same, assuming 'match_memory' RPC exists and takes 'p_user_id' (uuid)
            vec = self.model.encode(query).tolist()
            res = self.supabase.rpc("match_memory", {
                "query_embedding": vec,
                "match_threshold": 0.5,
                "match_count": 3,
                "p_user_id": user_id # User ID from LiveKit is TEXT, ensure it matches DB UUID type
            }).execute()
            memories = [f"Memory: {item['content']}" for item in res.data if item['content']]
            return "\n".join(memories) if memories else "No relevant past memories."
        except Exception as e:
            print(f"❌ Vector Service Error searching memory: {e}")
            return "Error searching past memories."

    async def save_memory(self, user_id: str, content: str):
        """Saves a piece of content to the user's long-term memory asynchronously."""
        if not self.supabase or not content.strip():
            return

        def encode_sync(text):
            return self.model.encode(text.strip()).tolist()

        try:
            # Run synchronous encoding in a separate thread
            vec = await asyncio.to_thread(encode_sync, content)

            data = {
                "user_id": user_id,
                "content": content.strip(),
                "embedding": vec,
            }
            self.supabase.table("memory").insert(data).execute()
            print(f"💾 Vector Service: Saved new memory for {user_id}.")
        except Exception as e:
            print(f"❌ Vector Service Error saving memory: {e}")


class SessionService:
    """Manages the creation and logging for Live Wingman sessions."""
    def __init__(self):
        options = ClientOptions(postgrest_client_timeout=10)
        options.storage = None # Ensure storage attribute exists
        options.httpx_client = None # Ensure httpx_client attribute exists
        self.supabase: Client = create_client(settings.SUPABASE_URL, settings.SUPABASE_KEY, options=options)

    def start_session(self, user_id: str) -> str:
        """Creates a new session entry and returns its UUID."""
        if not self.supabase: return str(uuid.uuid4()) # Fallback ID
        try:
            # Note: user_id from LiveKit is TEXT, but DB expects UUID.
            # We assume a mechanism (or client app) ensures this maps correctly.
            result = self.supabase.table("sessions").insert({"user_id": user_id, "title": "Live Wingman Session"}).execute()
            session_id = result.data[0]['id']
            print(f"📝 Session Service: Started new session {session_id} for user {user_id}.")
            return session_id
        except Exception as e:
            print(f"❌ Session Service Error starting session: {e}")
            return str(uuid.uuid4()) # Fallback ID

    def log_message(self, session_id: str, role: str, content: str):
        """Logs a message (user or agent) to the session_logs table."""
        if not self.supabase or session_id not in LIVE_SESSIONS.values(): return
        try:
            self.supabase.table("session_logs").insert({
                "session_id": session_id,
                "role": role,
                "content": content,
            }).execute()
        except Exception as e:
            print(f"❌ Session Service Error logging message: {e}")

    def fetch_consultant_history(self, user_id: str, limit: int = 5) -> str:
        """Fetches the last N Q&A pairs from consultant_logs."""
        if not self.supabase: return "No past consultant history."
        try:
            # Assuming user_id is the UUID from auth.users
            res = self.supabase.table("consultant_logs").select("question, answer").eq("user_id", user_id).order("created_at", desc=True).limit(limit).execute()

            history_lines = []
            for item in reversed(res.data): # Reverse to show oldest first
                history_lines.append(f"Q: {item['question']}")
                history_lines.append(f"A: {item['answer']}")

            history_str = "\n".join(history_lines)
            return history_str if history_str else "No past consultant history."
        except Exception as e:
            print(f"❌ Session Service Error fetching consultant history: {e}")
            return "Error fetching past consultant history."

    def log_consultant_qa(self, user_id: str, question: str, answer: str):
        """Logs the Q&A pair for the consultant mode."""
        if not self.supabase: return
        try:
            self.supabase.table("consultant_logs").insert({
                "user_id": user_id,
                "question": question,
                "answer": answer
            }).execute()
            print(f"📝 Session Service: Logged new consultant Q&A for {user_id}.")
        except Exception as e:
            print(f"❌ Session Service Error logging consultant Q&A: {e}")


class BrainService:
    """The Intelligence Layer (Groq/Llama 3)"""
    def __init__(self):
        self.client = Groq(api_key=settings.GROQ_KEY)
        print("🧠 Brain Service: Groq Client Initialized")

    def get_wingman_advice(self, user_id: str, transcript: str, graph_context: str, vector_context: str) -> str:
        """Uses the fast 8B model for real-time, low-latency advice."""
        system_prompt = (
            "You are a strategic Wingman AI named Bubbles. Your goal is to assist the user in real-time."
            "\n\nRULES:"
            "\n1. Analyze the transcript."
            "\n2. Use the GRAPH CONTEXT (Facts) and MEMORY (History)."
            "\n3. Provide ONE sharp, short advice sentence."
            "\n4. If the user is doing fine, or it's just noise, output exactly 'WAITING'."
            f"\n\nUSER ID: {user_id}"
            f"\nGRAPH CONTEXT:\n{graph_context}"
            f"\nMEMORY CONTEXT:\n{vector_context}"
        )
        try:
            completion = self.client.chat.completions.create(
                messages=[
                    {"role": "system", "content": system_prompt},
                    {"role": "user", "content": f"The user just said: {transcript}"}
                ],
                model=settings.WINGMAN_MODEL, # <-- Using the FAST model
                temperature=0.6,
                max_tokens=60
            )
            advice = completion.choices[0].message.content.strip()
            return advice
        except Exception as e:
            print(f"❌ Brain Service Error getting wingman advice: {e}")
            return "WAITING"

    def extract_knowledge(self, transcript: str) -> List[dict]:
        """Extracts facts for the knowledge graph."""
        prompt = "Extract relationships from the text. Return JSON ONLY: {'relationships': [{'source': 'A', 'target': 'B', 'relation': 'C'}]}. The entities must be clear."
        try:
            completion = self.client.chat.completions.create(
                messages=[{"role": "system", "content": prompt}, {"role": "user", "content": transcript}],
                model=settings.WINGMAN_MODEL, # Can use 8B for fast extraction
                response_format={"type": "json_object"}
            )
            # Ensure safe JSON parsing
            content = completion.choices[0].message.content
            relationships = json.loads(content).get("relationships", [])
            return [r for r in relationships if r.get('source') and r.get('target')] # Filter malformed
        except Exception as e:
            print(f"❌ Brain Service Error extracting knowledge: {e}")
            return []

    def ask_consultant(self, user_id: str, question: str, history: str, graph_context: str, vector_context: str) -> str:
        """Uses the powerful 70B model for detailed, context-aware answers."""
        system_prompt = (
            "You are an expert consultant AI named Bubbles. Your goal is to answer the user's detailed question "
            "based on all available context: history, graph facts, and long-term memories."
            "\n\nRULES:"
            "\n1. **Do not** mention 'vectors', 'graphs', or 'context'. Simply use the information naturally."
            "\n2. Provide a complete, short, and realistic answer."

            f"\n\n--- CONTEXT FOR BUBBLES ---"
            f"\nCONSULTANT HISTORY:\n{history}"
            f"\nGRAPH FACTS:\n{graph_context}"
            f"\nVEC MEMORIES:\n{vector_context}"
            f"\n---------------------------"
        )
        try:
            completion = self.client.chat.completions.create(
                messages=[
                    {"role": "system", "content": system_prompt},
                    {"role": "user", "content": question}
                ],
                model=settings.CONSULTANT_MODEL, # <-- Using the POWERFUL model
                temperature=0.7,
                max_tokens=400
            )
            answer = completion.choices[0].message.content
            return answer
        except Exception as e:
            print(f"❌ Brain Service Error asking consultant: {e}")
            return "I'm having trouble thinking right now, please try again in a moment. - Bubbles"

# Initialize Services
graph_svc = GraphService()
vector_svc = VectorService()
brain_svc = BrainService()
session_svc = SessionService()


# --- 3B. FastAPI Server (Token Generation & Consultant) ---

app = FastAPI()
app.add_middleware(CORSMiddleware, allow_origins=["*"], allow_methods=["*"], allow_headers=["*"])

@app.get("/")
def root():
    return {"status": "Bubbles Brain Online", "consultant_model": settings.CONSULTANT_MODEL, "wingman_model": settings.WINGMAN_MODEL}

@app.get("/getToken")
async def get_token(userId: str, roomName: str = "default-room"):
    """Generates a LiveKit JWT token for a user to join a room."""
    token = api.AccessToken(settings.LIVEKIT_API_KEY, settings.LIVEKIT_API_SECRET)
    token.with_identity(userId)
    token.with_name(userId)
    token.with_grants(api.VideoGrants(
        room_join=True, room=roomName, can_publish=True, can_subscribe=True
    ))
    jwt_token = token.to_jwt()
    return {"token": jwt_token, "url": settings.LIVEKIT_URL}

class ConsultantRequest(BaseModel):
    user_id: str # This should be the UUID used in Supabase
    question: str

@app.post("/ask_consultant")
async def ask_consultant_endpoint(req: ConsultantRequest):
    """Handles the detailed, asynchronous consultant queries (using 70B model)."""

    # 1. Fetch Contexts
    # Note: GraphService.load_graph() is called here to ensure graph is in RAM before finding context
    graph_svc.load_graph(req.user_id)
    g_ctx = graph_svc.find_context(req.user_id, req.question, top_k=10)
    v_ctx = vector_svc.search_memory(req.user_id, req.question)
    h_ctx = session_svc.fetch_consultant_history(req.user_id, limit=5)

    # 2. Get Answer from Powerful LLM
    answer = brain_svc.ask_consultant(req.user_id, req.question, h_ctx, g_ctx, v_ctx)

    # 3. Log the Q&A pair
    session_svc.log_consultant_qa(req.user_id, req.question, answer)

    # 4. Save and remove graph from memory
    graph_svc.save_graph(req.user_id)

    return {"answer": answer}

class WingmanRequest(BaseModel):
    user_id: str
    transcript: str

@app.post("/process_transcript_wingman")
async def process_transcript_wingman(req: WingmanRequest):
    """
    Receives a transcript (from 'Other') directly from the client.
    Returns immediate advice (Wingman mode).
    """
    user_id = req.user_id
    transcript = req.transcript

    print(f"📨 Wingman Request from {user_id}: {transcript}")

    # 1. Load Contexts
    graph_svc.load_graph(user_id)
    g_ctx = graph_svc.find_context(user_id, transcript)
    v_ctx = vector_svc.search_memory(user_id, transcript)

    # 2. Get Advice
    advice = brain_svc.get_wingman_advice(user_id, transcript, g_ctx, v_ctx)

    # 3. Extract Knowledge (Background Task)
    # We can do this synchronously for now or fire-and-forget
    new_rels = brain_svc.extract_knowledge(transcript)
    if new_rels:
        graph_svc.update_local_graph(user_id, new_rels)
        graph_svc.save_graph(user_id) # Save updates

    # 4. Save to Memory (Background Task)
    await vector_svc.save_memory(user_id, f"Other: {transcript}")

    return {"advice": advice}


# --- 3C. LiveKit Agent Worker (Wingman Mode) ---
# NOTE: This is kept for reference but might be unused if we switch to client-side Deepgram.

async def entrypoint(ctx: JobContext):
    user_id = ctx.room.name # Assuming room name is the user_id for simplicity in this demo
    print(f'🔴 AGENT CONNECTED to Room/User: {user_id}')

    # Initialize Session and Graph
    session_id = session_svc.start_session(user_id)
    LIVE_SESSIONS[user_id] = session_id
    graph_svc.load_graph(user_id)

    # Configure Deepgram with Diarization
    stt = deepgram.STT(
        api_key=settings.DEEPGRAM_KEY,
        model="nova-2",
        language="en-US",
        smart_format=True,
        diarize=True,
    )
    await ctx.connect(auto_subscribe=AutoSubscribe.AUDIO_ONLY)

    @ctx.room.on('track_subscribed')
    def on_track_subscribed(track, publication, participant):
        if track.kind == 'audio' and participant.identity == user_id:
            print(f"\n🔊 Agent: Subscribed to audio track from {user_id}.")
            stream = stt.stream()

            async def process_transcripts():
                async for event in stream:
                    if event.type == deepgram.STTEventType.FINAL_TRANSCRIPT:
                        transcript = event.alternatives[0].text
                        if not transcript.strip(): continue

                        # 1. Extract Speaker & Log
                        # Note: Deepgram diarization returns speaker info in words. 
                        # We assume the first word's speaker represents the segment.
                        speaker_id = 0
                        if hasattr(event.alternatives[0], 'words') and event.alternatives[0].words:
                            speaker_id = event.alternatives[0].words[0].speaker
                        
                        speaker_role = "user" if speaker_id == 0 else "other"
                        
                        session_svc.log_message(LIVE_SESSIONS[user_id], speaker_role, transcript)
                        print(f"🗣️ {user_id} [Speaker {speaker_id}]: {transcript}")
                        # Send Transcript to Client
                        t_payload = json.dumps({'type': 'transcript', 'text': transcript, 'speaker': speaker_role, 'is_final': True})
                        await ctx.room.local_participant.publish_data(t_payload, reliable=True)

                        # 2. Logic: Only generate advice for 'Others' (The person the user is talking to)
                        if speaker_role == "other":
                            # Gather Contexts (Graph, Vector)
                            g_ctx = graph_svc.find_context(user_id, transcript)
                            v_ctx = vector_svc.search_memory(user_id, transcript)

                            # Get Real-time Advice (Fast 8B Model)
                            # We pass the transcript of the 'other' person so the Wingman can suggest what to say/do.
                            advice = brain_svc.get_wingman_advice(user_id, transcript, g_ctx, v_ctx)

                            if advice != "WAITING":
                                # Send Advice to Client
                                print(f"💡 Wingman Suggestion: {advice}")
                                payload = json.dumps({'type': 'assistant_response', 'text': advice, 'timestamp': datetime.now().isoformat()})
                                await ctx.room.local_participant.publish_data(payload, reliable=True)

                                # Log Agent Response
                                session_svc.log_message(LIVE_SESSIONS[user_id], 'agent', advice)

                        # 3. Extract Knowledge & Update In-Memory Graph (From BOTH speakers)
                        new_rels = brain_svc.extract_knowledge(transcript)
                        if new_rels:
                            graph_svc.update_local_graph(user_id, new_rels)

                        # 4. Save Transcript to Vector Memory
                        await vector_svc.save_memory(user_id, f"Speaker {speaker_id}: {transcript}")

            async def pump_audio():
                async for frame in track.stream():
                    stream.push_frame(frame)
                await stream.aclose()

            asyncio.create_task(process_transcripts())
            asyncio.create_task(pump_audio())

    @ctx.room.on('participant_disconnected')
    def on_participant_disconnected(participant):
        if participant.identity == user_id:
            print(f"\n👋 Agent: User Left: {user_id}")

            # Final Persistence Steps
            graph_svc.save_graph(user_id) # Save in-memory graph to DB

            # Clean up session state
            if user_id in LIVE_SESSIONS:
                del LIVE_SESSIONS[user_id]
                print(f"✅ Session and Graph data cleared for {user_id}.")


# --- 3D. Main Execution (Server + Worker + Ngrok) ---

async def main():
    print("🚀 Main: Starting Bubbles Brain Backend...")

    # Setup Ngrok
    ngrok.set_auth_token(settings.NGROK_TOKEN)
    for t in ngrok.get_tunnels():
        try:
            ngrok.disconnect(t.public_url)
        except: pass

    public_url = ngrok.connect(settings.PORT).public_url
    print(f"\n🚀 BUBBLES BACKEND LIVE")
    print(f"🔗 Base URL: {public_url}")
    print(f"🔑 Token Endpoint: {public_url}/getToken?userId=UUID_FROM_AUTH_USERS")
    print(f"🧠 Consultant Model: {settings.CONSULTANT_MODEL} | ⚡ Wingman Model: {settings.WINGMAN_MODEL}")

    # QR Code for easy client setup
    qr = qrcode.QRCode(box_size=5, border=2)
    qr.add_data(public_url)
    qr.make(fit=True)
    try:
        from IPython.display import display
        print("\n👇 SCAN THIS IN FLUTTER APP 👇")
        display(qr.make_image(fill_color="black", back_color="white"))
    except: pass

    # ADAPTER: Define a request_fnc for the LiveKit Worker
    async def request_fnc(job_request: JobRequest):
        # IMPORTANT: Use job_request.participant_identity as the user_id for consistency
        print(f"⚡ Worker: Accepting Job for User: {job_request.participant_identity} in Room: {job_request.room_name}")
        await job_request.accept(entrypoint)

    opts = WorkerOptions(
        request_fnc=request_fnc,
        ws_url=settings.LIVEKIT_URL,
        api_key=settings.LIVEKIT_API_KEY,
        api_secret=settings.LIVEKIT_API_SECRET
    )
    worker = Worker(opts)

    config = uvicorn.Config(app, host=settings.HOST, port=settings.PORT, log_level="error")
    server = uvicorn.Server(config)

    print("▶️ Main: Running server and worker concurrently...")
    # We run both, but the client might not connect to LiveKit anymore.
    await asyncio.gather(server.serve(), worker.run())

if __name__ == "__main__":
    try:
        loop = asyncio.get_event_loop()
        loop.run_until_complete(main())
    except KeyboardInterrupt:
        print("\nShutting down...")
