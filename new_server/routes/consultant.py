from fastapi import APIRouter, Request
from models.schemas import ConsultantRequest, BatchConsultantRequest, ConsultantStreamRequest
from utils.rate_limit import limiter
from utils.text_sanitizer import sanitize_input
from services.brain_service import brain_svc

router = APIRouter(prefix="/v1")

@router.post("/ask_consultant")
@limiter.limit("10/minute")
async def ask_consultant_endpoint(request: Request, req: ConsultantRequest):
    sanitized_q = sanitize_input(req.question)
    # TODO: Fetch context and invoke brain_svc
    return {"answer": f"Simulated answer for {sanitized_q}"}

@router.post("/ask_consultant_stream")
@limiter.limit("10/minute")
async def ask_consultant_stream_endpoint(request: Request, req: ConsultantStreamRequest):
    # TODO: Implement streaming response
    return {"answer": "Simulated streaming answer"}

@router.post("/ask_consultant/batch")
async def ask_consultant_batch(req: BatchConsultantRequest):
    return {"answers": ["Answer 1", "Answer 2"]}
