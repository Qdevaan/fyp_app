# Bubbles 🫧
### Your AI Wingman & Strategic Consultant

**Bubbles** is a next-generation "Dual-AI" application designed to augment human social and professional interactions. It combines real-time conversational coaching ("Wingman") with deep, context-aware personal consulting ("Consultant").

---

## 🚀 Key Features

### 1. The Wingman (Real-Time Mode)
*   **Instant Advice:** Listens to your conversations in real-time and provides sharp, strategic advice in under 2 seconds.
*   **Context Aware:** Uses a local Knowledge Graph to understand relationships and facts about the people you are talking to.
*   **Privacy First:** Processes audio streams securely, extracting insights without retaining unnecessary raw audio.
*   **Powered by:** `Llama 3 8B` (Groq) for ultra-low latency.

### 2. The Consultant (Deep Dive Mode)
*   **Strategic Planning:** Ask detailed questions about your career, relationships, or goals.
*   **Long-Term Memory:** Remembers every past session and interaction using Vector Search (Supabase).
*   **Detailed Answers:** providing comprehensive, thoughtful guidance based on your entire history.
*   **Powered by:** `Llama 3 70B` (Groq) for maximum reasoning capability.

---

## 🛠️ Technology Stack

### Frontend (Mobile App)
*   **Framework:** [Flutter](https://flutter.dev/) (Dart)
*   **State Management:** Provider
*   **Auth & Database:** [Supabase](https://supabase.com/)
*   **Real-Time Audio:** [LiveKit](https://livekit.io/)
*   **Animations:** Flutter Animate

### Backend (The Brain)
*   **Server:** Python [FastAPI](https://fastapi.tiangolo.com/)
*   **AI Inference:** [Groq](https://groq.com/) (LPU™ Inference Engine)
*   **Graph Database:** NetworkX (In-Memory/Persisted Knowledge Graphs)
*   **Vector Database:** Supabase pgvector
*   **Speech-to-Text:** Deepgram Nova-2 (via LiveKit)
*   **Tunneling:** Ngrok (for local development access)

---

## 📂 Project Structure

```bash
fyp_app/
├── lib/
│   ├── main.dart            # App entry point & Routing
│   ├── screens/             # UI Screens (Home, Login, Consultant, etc.)
│   ├── services/            # Logic (Auth, API, LiveKit, Connections)
│   ├── providers/           # State Management (Theme, etc.)
│   ├── widgets/             # Reusable UI Components
│   └── theme/               # App Design System
├── server/
│   ├── server.py            # Main FastAPI Backend & AI Logic
│   └── server_bubbles.ipynb # Prototyping & Experiments
├── Documentation/           # Project Reports & PDFs
└── pubspec.yaml             # Flutter Dependencies
```

---

## ⚡ Getting Started

### Prerequisites
1.  **Flutter SDK** (3.10+) installed.
2.  **Python 3.10+** installed.
3.  **Supabase Project** with `memory`, `knowledge_graphs`, `sessions` tables.
4.  **API Keys** for: Groq, LiveKit, Deepgram, Ngrok.

### Step 1: Backend Setup
 Navigate to the server directory and install dependencies:

```bash
cd server
pip install fastapi uvicorn list-of-dependencies... 
# (Recommended: Create a venv and install: fastapi uvicorn groq supabase livekit-api livekit-plugins-deepgram networkx sentence-transformers pyngrok)
```

Configure your environment variables (in `server.py` or `.env`):
*   `GROQ_API_KEY`
*   `SUPABASE_URL` & `SUPABASE_KEY`
*   `LIVEKIT_API_KEY`, `Secret`, & `URL`
*   `DEEPGRAM_KEY`

Run the server:
```bash
python server.py
```
*The terminal will display a QR Code and a Public URL. Keep this running.*

### Step 2: Frontend Setup
From the root directory, install Flutter packages:

```bash
flutter pub get
```

Run the app on your device or emulator:

```bash
flutter run
```

---

## 🤝 Contributing
1.  Fork the repository
2.  Create your feature branch (`git checkout -b feature/AmazingFeature`)
3.  Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4.  Push to the branch (`git push origin feature/AmazingFeature`)
5.  Open a Pull Request

---

## 📄 License
This project is part of a Final Year Project (FYP) and is proprietary.
