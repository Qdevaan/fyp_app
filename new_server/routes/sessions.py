from fastapi import APIRouter, Request, HTTPException
from models.schemas import StartSessionRequest, EndSessionRequest, TokenRequest, SaveSessionRequest
from utils.rate_limit import limiter
from utils.text_sanitizer import sanitize_input
# from services.session_service import SessionService

router = APIRouter(prefix="/v1")

@router.post("/start_session")
@limiter.limit("10/minute")
async def start_session_endpoint(request: Request, req: StartSessionRequest):
    # Logic for starting session
    return {"status": "success"}

@router.post("/getToken")
@limiter.limit("15/minute")
async def get_token(request: Request, req: TokenRequest):
    # Livekit token generation logic
    return {"token": "generated_token"}

@router.post("/save_session")
@limiter.limit("10/minute")
async def save_session_endpoint(request: Request, req: SaveSessionRequest):
    # Logic for saving
    return {"status": "success"}

@router.post("/end_session")
@limiter.limit("10/minute")
async def end_session_endpoint(request: Request, req: EndSessionRequest):
    # Logic for ending
    return {"status": "success"}
