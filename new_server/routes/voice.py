from fastapi import APIRouter, Request, UploadFile, File, Form
from models.schemas import VoiceCommandRequest
from utils.rate_limit import limiter
from utils.text_sanitizer import sanitize_input

router = APIRouter(prefix="/v1")

@router.post("/voice_command")
@limiter.limit("15/minute")
async def voice_command(request: Request, req: VoiceCommandRequest):
    # TODO: Process voice command
    return {"status": "processed", "command": req.command}

@router.post("/enroll")
@limiter.limit("5/minute")
async def enroll_voice(
    request: Request,
    user_id: str = Form(...),
    user_name: str = Form(...),
    file: UploadFile = File(...),
):
    # TODO: Process voice enrollment
    return {"status": "enrolled", "user": user_name}
