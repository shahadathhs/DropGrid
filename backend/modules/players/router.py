from fastapi import APIRouter
from sqlalchemy import select
from sqlalchemy.exc import IntegrityError

from core.exceptions import ConflictException
from core.security.deps import CurrentPlayer, DbSession
from models.player import Player
from modules.players.schemas import PlayerOut, PlayerUpdateIn

router = APIRouter(prefix="/players", tags=["players"])


@router.get("/me", response_model=PlayerOut)
async def me(player: CurrentPlayer) -> PlayerOut:
    return PlayerOut.model_validate(player)


@router.patch("/me", response_model=PlayerOut)
async def rename(data: PlayerUpdateIn, player: CurrentPlayer, db: DbSession) -> PlayerOut:
    taken = await db.execute(
        select(Player.id).where(Player.username == data.username, Player.id != player.id).limit(1)
    )
    if taken.first() is not None:
        raise ConflictException("Username is already taken")
    player.username = data.username
    try:
        await db.commit()
    except IntegrityError:
        await db.rollback()
        raise ConflictException("Username is already taken") from None
    return PlayerOut.model_validate(player)


@router.delete("/me", status_code=204)
async def delete_account(player: CurrentPlayer, db: DbSession) -> None:
    await db.delete(player)
    await db.commit()
