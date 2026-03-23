from slowapi import Limiter
from slowapi.util import get_remote_address

# Rate limiter — keyed by remote IP
limiter = Limiter(key_func=get_remote_address)
