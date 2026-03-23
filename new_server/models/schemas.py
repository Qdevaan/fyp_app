from typing import List, Dict, Optional, Any
from pydantic import BaseModel, Field

class StartSessionRequest(BaseModel):
    user_id: str = Field(..., min_length=1)
    mode: str = "live_wingman"
    target_entity_id: Optional[int] = None
    is_ephemeral: bool = False
    is_multiplayer: bool = False
    persona: str = "casual"

class TokenRequest(BaseModel):
    userId: str
    roomName: str = "default-room"

class ConsultantRequest(BaseModel):
    user_id: str = Field(..., min_length=1, description="Supabase user UUID")
    question: str = Field(..., min_length=1, max_length=5000, description="User question")
    session_id: Optional[str] = Field(None, description="Existing consultant session ID to append to")
    mode: str = Field("consultant", description="Mode for consultant")
    persona: str = Field("casual", description="Customizable Persona Tone")

class ConsultantStreamRequest(BaseModel):
    user_id: str
    question: str
    session_id: Optional[str] = None
    mode: str = "consultant"
    persona: str = "casual"

class EntityQueryRequest(BaseModel):
    user_id: str = Field(..., min_length=1)
    entity_name: str = Field(..., min_length=1, max_length=200)

class WingmanRequest(BaseModel):
    user_id: str
    transcript: str
    session_id: Optional[str] = None
    speaker_role: str = "others"
    speaker_label: Optional[str] = None
    mode: str = Field("live_wingman", description="Mode for wingman")
    persona: str = Field("casual", description="Customizable Persona Tone")

class SaveSessionRequest(BaseModel):
    user_id: str
    transcript: str
    logs: List[Dict[str, Any]]
    is_ephemeral: bool = False

class EndSessionRequest(BaseModel):
    session_id: str
    user_id: str

class FeedbackRequest(BaseModel):
    user_id: str = Field(..., min_length=1)
    session_id: Optional[str] = None
    session_log_id: Optional[str] = None
    consultant_log_id: Optional[str] = None
    feedback_type: str = Field(..., description="thumbs | star | text")
    value: Optional[int] = Field(None, ge=-1, le=5)
    comment: Optional[str] = Field(None, max_length=1000)

class BatchConsultantRequest(BaseModel):
    user_id: str
    questions: List[str]
    mode: str = "casual"

class VoiceCommandRequest(BaseModel):
    user_id: str = Field(..., min_length=1, description="Supabase user UUID")
    command: str = Field(..., min_length=1, max_length=2000, description="Voice command text")
