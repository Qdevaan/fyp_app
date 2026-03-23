import networkx as nx
from typing import Dict, List
from database import db
# GraphService logic here

class GraphService:
    """Manages specific Knowledge Graphs for EACH connected user."""
    def __init__(self):
        self.active_graphs: Dict[str, nx.Graph] = {}
        self.model = None  
        self.supabase = db

    def load_graph(self, user_id: str):
        pass

    def save_graph(self, user_id: str):
        pass

    def _keyword_nodes(self, G: nx.Graph, text: str) -> set:
        pass

    def find_context(self, user_id: str, text: str, top_k: int = 5) -> str:
        return "No known graph facts."

    def update_local_graph(self, user_id: str, updates: List[dict]):
        pass
