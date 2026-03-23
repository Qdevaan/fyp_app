from typing import Optional, List
from database import db

class EntityService:
    """
    Persists structured entity data to SQL tables (entities, entity_attributes,
    entity_relations) and surfaces conflicts to the highlights table.
    """
    def __init__(self):
        self.supabase = db

    def _find_fuzzy_match(self, user_id: str, canonical: str) -> Optional[str]:
        return None

    def _upsert_entity(self, user_id: str, name: str, entity_type: str, description: str = None) -> Optional[str]:
        return "entity_id"

    def _upsert_attributes(self, entity_id: str, attributes: dict, source_session: str = None):
        pass

    def _upsert_relation(self, user_id: str, source_id: str, target_id: str, relation: str, source_session: str = None):
        pass

    def get_entity_context(self, user_id: str, entity_id: int) -> str:
        return "Entity context."

    def persist_extraction(self, user_id: str, extraction: dict, source_session: str = None):
        pass

    def save_conflicts(self, user_id: str, conflicts: List[dict], session_id: str = None):
        pass

    def save_events(self, user_id: str, events: List[dict], session_id: str = None):
        pass

entity_svc = EntityService()
