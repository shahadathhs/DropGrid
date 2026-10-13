from typing import Annotated

from fastapi import Depends
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy.ext.asyncio import AsyncSession

from core.database import get_db
from core.exceptions import UnauthorizedException
from core.security.jwt import decode_token
from models.player import Player

_bearer = HTTPBearer(auto_error=False)

DbSession = Annotated[AsyncSession, Depends(get_db)]


async def get_current_player(
    db: DbSession,
    credentials: Annotated[HTTPAuthorizationCredentials | None, Depends(_bearer)],
) -> Player:
    """Resolve the Bearer access token to a live player, or raise 401."""
    if credentials is None:
        raise UnauthorizedException()
    claims = decode_token(credentials.credentials, "access")
    if claims is None:
        raise UnauthorizedException()
    player = await db.get(Player, claims.player_id)
    # A stale password_version means the password changed since this token was issued.
    if player is None or player.password_version != claims.password_version:
        raise UnauthorizedException()
    return player


CurrentPlayer = Annotated[Player, Depends(get_current_player)]
