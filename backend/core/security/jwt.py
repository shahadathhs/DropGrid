import time
import uuid
from dataclasses import dataclass
from typing import Literal

import jwt

from core.config import settings

TokenType = Literal["access", "refresh"]

_REQUIRED_CLAIMS = ["sub", "type", "pv", "iat", "exp"]


@dataclass(frozen=True)
class TokenClaims:
    player_id: uuid.UUID
    password_version: int


def _encode(
    player_id: uuid.UUID,
    password_version: int,
    token_type: TokenType,
    lifetime_seconds: int,
) -> str:
    now = int(time.time())
    payload = {
        "sub": str(player_id),
        "type": token_type,
        "pv": password_version,
        "iat": now,
        "exp": now + lifetime_seconds,
        # Unique per token so two refreshes in the same second differ.
        "jti": uuid.uuid4().hex,
    }
    return jwt.encode(payload, settings.jwt_secret, algorithm=settings.jwt_algorithm)


def create_access_token(player_id: uuid.UUID, password_version: int) -> str:
    lifetime = settings.access_token_expire_minutes * 60
    return _encode(player_id, password_version, "access", lifetime)


def create_refresh_token(player_id: uuid.UUID, password_version: int) -> str:
    lifetime = settings.refresh_token_expire_days * 24 * 60 * 60
    return _encode(player_id, password_version, "refresh", lifetime)


def decode_token(token: str, expected_type: TokenType) -> TokenClaims | None:
    """Return the claims of a valid, unexpired token of the expected type, else None."""
    try:
        payload = jwt.decode(
            token,
            settings.jwt_secret,
            algorithms=[settings.jwt_algorithm],
            options={"require": _REQUIRED_CLAIMS},
        )
    except jwt.PyJWTError:
        return None
    if payload.get("type") != expected_type:
        return None
    password_version = payload.get("pv")
    if not isinstance(password_version, int) or isinstance(password_version, bool):
        return None
    try:
        player_id = uuid.UUID(str(payload["sub"]))
    except ValueError:
        return None
    return TokenClaims(player_id=player_id, password_version=password_version)
