from fastapi import APIRouter, Request
from models.schemas import EntityQueryRequest
from utils.rate_limit import limiter
from services.entity_service import entity_svc

router = APIRouter(prefix="/v1")

@router.post("/ask_entity")
@limiter.limit("15/minute")
async def ask_entity_endpoint(request: Request, req: EntityQueryRequest):
    # TODO: Entity query logic
    return {"status": "success"}

@router.delete("/entities/{entity_id}")
async def delete_entity(entity_id: int):
    # TODO: Entity deletion
    return {"status": "deleted"}

@router.delete("/sessions/{session_id}")
async def delete_session(session_id: str):
    return {"status": "deleted"}

@router.delete("/memories/{memory_id}")
async def delete_memory(memory_id: int):
    return {"status": "deleted"}

@router.get("/graph_export/{user_id}")
async def get_graph_export(user_id: str):
    return {"graph": {}}
