import os
import time

class Settings:
    # Services
    DEEPGRAM_KEY: str = os.getenv("DEEPGRAM_KEY", "dummy")
    
    # LIVEKIT: Real-time Audio/Video
    LIVEKIT_URL: str = os.getenv("LIVEKIT_URL", "")
    LIVEKIT_API_KEY: str = os.getenv("LIVEKIT_API_KEY", "")
    LIVEKIT_API_SECRET: str = os.getenv("LIVEKIT_API_SECRET", "")
    
    # GROQ: LLM Inference
    GROQ_KEY: str = os.getenv("GROQ_API_KEY", "")
    
    # SUPABASE: Database & Vectors
    SUPABASE_URL: str = os.getenv("SUPABASE_URL", "")
    SUPABASE_KEY: str = os.getenv("SUPABASE_KEY", "")
    SUPABASE_SERVICE_KEY: str = os.getenv("SUPABASE_SERVICE_KEY", "")
    
    # AI Models
    EMBEDDING_MODEL: str = "all-MiniLM-L6-v2"
    CONSULTANT_MODEL: str = "llama-3.3-70b-versatile" 
    WINGMAN_MODEL: str = "llama-3.1-8b-instant" 
    
    # Server Settings
    HOST: str = "0.0.0.0"
    PORT: int = 8000
    ALLOWED_ORIGINS: str = os.getenv("ALLOWED_ORIGINS", "*")

settings = Settings()

os.environ['LIVEKIT_URL'] = settings.LIVEKIT_URL
os.environ['LIVEKIT_API_KEY'] = settings.LIVEKIT_API_KEY
os.environ['LIVEKIT_API_SECRET'] = settings.LIVEKIT_API_SECRET

SERVER_START_TIME = time.time()
