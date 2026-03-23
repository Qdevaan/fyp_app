from sentence_transformers import SentenceTransformer
from database import db
from config import settings

class VectorService:
    """Long-Term Memory (Supabase Vector Store)"""
    def __init__(self):
        print("🧠 Vector Service: Loading Embedding Model (MiniLM)...")
        self.model = SentenceTransformer(settings.EMBEDDING_MODEL)
        self.supabase = db
        print("✅ Vector Service: Embedding Model Loaded & DB Connected")

    def search_memory(self, user_id: str, query: str) -> str:
        """Searches long-term memory via vector similarity."""
        # TODO: Implement RPC call to match_documents
        return "Vector context."

    async def save_memory(self, user_id: str, content: str):
        """Saves a piece of content to the user's long-term memory asynchronously."""
        # TODO: Encode and insert into memory table
        pass

vector_svc = VectorService()
