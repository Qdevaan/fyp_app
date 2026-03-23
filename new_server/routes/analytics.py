from fastapi import APIRouter, Request
from models.schemas import FeedbackRequest
from utils.rate_limit import limiter

router = APIRouter(prefix="/v1")

@router.post("/save_feedback")
@limiter.limit("30/minute")
async def save_feedback(request: Request, req: FeedbackRequest):
    # TODO: Save feedback
    return {"status": "saved"}

@router.get("/session_analytics/{session_id}")
@limiter.limit("20/minute")
async def get_session_analytics(request: Request, session_id: str):
    # TODO: return analytics
    return {"session": session_id, "analytics": {}}

@router.get("/coaching_report/{session_id}")
@limiter.limit("10/minute")
async def get_coaching_report(request: Request, session_id: str):
    # TODO: return coaching report
    return {"session": session_id, "report": "Report content"}
