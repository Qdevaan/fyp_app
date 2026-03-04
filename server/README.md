# Bubbles AI — Backend Server

## Canonical file: `new_server.py`

`new_server.py` is the **active, production server**. It contains all current endpoints, services, and LiveKit agent logic. Use this file for all development and deployment.

`server.py` is an older iteration kept for reference. It is **not deployed** and will be removed in a future cleanup.

---

## Quick Start (Local)

```bash
pip install -r requirements.txt
python new_server.py
```

The server starts on `http://0.0.0.0:8000` and automatically creates an ngrok tunnel. The public URL is printed to the console and displayed as a QR code.

---

## Quick Start (Google Colab)

1. Upload `new_server.py` and `requirements.txt` to your Colab session.
2. Run the top install cell (the `!pip install ...` line is at the top of the file — just uncomment it).
3. Set your environment variables (or paste keys directly into `Settings` for a quick demo).
4. Run the file. Scan the QR code in the Flutter app under **Connections → Scan QR**.

---

## Environment Variables

| Variable              | Description                                  |
|-----------------------|----------------------------------------------|
| `SUPABASE_URL`        | Supabase project URL                         |
| `SUPABASE_KEY`        | Supabase anon key (client-safe reads)        |
| `SUPABASE_SERVICE_KEY`| Supabase service role key (server-side only) |
| `GROQ_API_KEY`        | Groq LLM inference key                       |
| `DEEPGRAM_KEY`        | Deepgram STT key                             |
| `LIVEKIT_URL`         | LiveKit server WebSocket URL                 |
| `LIVEKIT_API_KEY`     | LiveKit API key                              |
| `LIVEKIT_API_SECRET`  | LiveKit API secret                           |
| `NGROK_TOKEN`         | ngrok authtoken for public tunneling         |

Copy `.env.example` to `.env` and fill in your keys, or export them as environment variables before running.

---

## Key Endpoints

| Method | Path                         | Description                                  |
|--------|------------------------------|----------------------------------------------|
| POST   | `/start_session`             | Creates a live Wingman session record        |
| POST   | `/process_transcript_wingman`| Processes a transcript and inserts LLM row   |
| POST   | `/end_session`               | Summarises session, marks it completed       |
| POST   | `/ask_consultant`            | Single-turn consultant Q&A                   |
| POST   | `/ask_consultant_stream`     | Streaming consultant via SSE                 |
| POST   | `/enroll`                    | Enrolls user voice embedding                 |
| GET    | `/getToken`                  | Issues a LiveKit room token                  |
| GET    | `/health`                    | Health check                                 |

---

## Architecture

```
new_server.py
├── Settings          – env-based config
├── GraphService      – per-user NetworkX knowledge graph (load/save/query)
├── VectorService     – SentenceTransformer embeddings → Supabase pgvector
├── SessionService    – session & consultant_log CRUD
├── BrainService      – Groq LLM calls (Wingman + Consultant)
└── FastAPI routes    – HTTP endpoints + SSE streaming
```
