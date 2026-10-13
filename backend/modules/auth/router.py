from functools import lru_cache

from fastapi import APIRouter, Depends
from sqlalchemy import select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.sql.elements import ColumnElement

from core.exceptions import ConflictException, UnauthorizedException
from core.ratelimit import rate_limit
from core.security.deps import DbSession
from core.security.jwt import create_access_token, create_refresh_token, decode_token
from core.security.password import hash_password, verify_password
from models.player import Player
from modules.auth.schemas import LoginIn, RefreshIn, RegisterIn, TokenPair

router = APIRouter(prefix="/auth", tags=["auth"])

INVALID_CREDENTIALS = "Invalid email or password"
INVALID_REFRESH = "Invalid or expired refresh token"


@lru_cache(maxsize=1)
def _dummy_hash() -> str:
    """Hash checked against when the email is unknown, so timing does not reveal accounts."""
    return hash_password("dummy-password-for-timing")


def _issue_tokens(player: Player) -> TokenPair:
    return TokenPair(
        access_token=create_access_token(player.id, player.password_version),
        refresh_token=create_refresh_token(player.id, player.password_version),
    )


@router.post(
    "/register",
    response_model=TokenPair,
    status_code=201,
    dependencies=[Depends(rate_limit("register"))],
)
async def register(data: RegisterIn, db: DbSession) -> TokenPair:
    if await _exists(db, Player.email == data.email):
        raise ConflictException("Email is already registered")
    if await _exists(db, Player.username == data.username):
        raise ConflictException("Username is already taken")

    player = Player(
        email=data.email,
        username=data.username,
        password_hash=hash_password(data.password),
        password_version=0,
        best_score=0,
        total_lines=0,
        games_played=0,
    )
    db.add(player)
    try:
        await db.commit()
    except IntegrityError:
        # Lost a race with a concurrent registration for the same email or username.
        await db.rollback()
        raise ConflictException("Email or username is already taken") from None
    return _issue_tokens(player)


@router.post("/login", response_model=TokenPair, dependencies=[Depends(rate_limit("login"))])
async def login(data: LoginIn, db: DbSession) -> TokenPair:
    player = (
        await db.execute(select(Player).where(Player.email == data.email))
    ).scalar_one_or_none()
    if player is None:
        verify_password(data.password, _dummy_hash())
        raise UnauthorizedException(INVALID_CREDENTIALS)
    if not verify_password(data.password, player.password_hash):
        raise UnauthorizedException(INVALID_CREDENTIALS)
    return _issue_tokens(player)


@router.post("/refresh", response_model=TokenPair, dependencies=[Depends(rate_limit("refresh"))])
async def refresh(data: RefreshIn, db: DbSession) -> TokenPair:
    claims = decode_token(data.refresh_token, "refresh")
    if claims is None:
        raise UnauthorizedException(INVALID_REFRESH)
    player = await db.get(Player, claims.player_id)
    if player is None or player.password_version != claims.password_version:
        raise UnauthorizedException(INVALID_REFRESH)
    return _issue_tokens(player)


async def _exists(db: AsyncSession, condition: ColumnElement[bool]) -> bool:
    result = await db.execute(select(Player.id).where(condition).limit(1))
    return result.first() is not None
