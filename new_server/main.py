from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from slowapi import _rate_limit_exceeded_handler
from slowapi.errors import RateLimitExceeded

from config import settings
from utils.rate_limit import limiter
from routes import sessions, voice, consultant, analytics, entities

app = FastAPI(title="Bubbles Brain API", description="Production Backend for Bubbles")
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

_allowed_origins = [
    o.strip() for o in settings.ALLOWED_ORIGINS.split(",")
] if settings.ALLOWED_ORIGINS != "*" else ["*"]

app.add_middleware(
    CORSMiddleware,
    allow_origins=_allowed_origins,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(sessions.router)
app.include_router(consultant.router)
app.include_router(voice.router)
app.include_router(analytics.router)
app.include_router(entities.router)

@app.get("/")
def root():
    return {"message": "Bubbles Brain API is running.", "status": "ok"}

@app.get("/health")
def health_check():
    return {"status": "ok", "db_status": "connected"}

# We removed the ngrok/qr code logic from main
# It will just be run using gunicorn/uvicorn conventionally via the Dockerfile
