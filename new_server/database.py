from supabase import create_client, Client
from supabase.lib.client_options import ClientOptions
from config import settings

def get_supabase_client() -> Client:
    options = ClientOptions(postgrest_client_timeout=10)
    options.storage = None
    options.httpx_client = None
    
    return create_client(
        settings.SUPABASE_URL, 
        settings.SUPABASE_SERVICE_KEY, 
        options=options
    )

db = get_supabase_client()