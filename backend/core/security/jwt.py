import time
import uuid

import jwt

from core.config import settings


def _encode(payload: dict, lifetime_seconds: int) -> str:
    now = int(time.time())
    return jwt.encode(
        {**payload, "iat": now, "exp": now + lifetime_seconds},
        settings.jwt_secret,
        algorithm=settings.jwt_algorithm,
    )


def create_access_token(player_id: uuid.UUID) -> str:
    lifetime = settings.access_token_expire_minutes * 60
    return _encode({"sub": str(player_id), "type": "access"}, lifetime)


def create_refresh_token(player_id: uuid.UUID) -> str:
    return _encode(
        {"sub": str(player_id), "type": "refresh"},
        settings.refresh_token_expire_days * 24 * 60 * 60,
    )


def decode_token(token: str, expected_type: str) -> str | None:
    """Return the player id from a valid token of the expected type, else None."""
    try:
        payload = jwt.decode(token, settings.jwt_secret, algorithms=[settings.jwt_algorithm])
    except jwt.PyJWTError:
        return None
    if payload.get("type") != expected_type:
        return None
    return payload.get("sub")
