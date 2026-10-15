from fastapi import APIRouter, HTTPException
from sqlalchemy import select

from core.game_limits import max_plausible_score
from core.security.deps import CurrentPlayer, DbSession
from models.player import Player
from modules.players.schemas import PlayerOut
from modules.scores.schemas import LeaderboardEntry, LeaderboardOut, SyncIn

router = APIRouter(tags=["scores"])

LEADERBOARD_SIZE = 50


def _check_plausible(data: SyncIn) -> None:
    if data.games_played == 0 and (data.total_lines > 0 or data.best_score > 0):
        raise HTTPException(422, detail="Implausible stats: progress without any games played")
    if data.best_score > max_plausible_score(data.total_lines):
        raise HTTPException(422, detail="Implausible stats: best_score is too high for total_lines")


@router.post("/sync", response_model=PlayerOut)
async def sync(data: SyncIn, player: CurrentPlayer, db: DbSession) -> PlayerOut:
    _check_plausible(data)
    # Lock the row so concurrent syncs for one player cannot read the same
    # baseline and overwrite each other's max (Postgres; SQLite ignores FOR UPDATE).
    locked = (
        await db.execute(
            select(Player)
            .where(Player.id == player.id)
            .with_for_update()
            .execution_options(populate_existing=True)
        )
    ).scalar_one()
    locked.best_score = max(locked.best_score, data.best_score)
    locked.total_lines = max(locked.total_lines, data.total_lines)
    locked.games_played = max(locked.games_played, data.games_played)
    await db.commit()
    return PlayerOut.model_validate(locked)


@router.get("/leaderboard", response_model=LeaderboardOut)
async def leaderboard(db: DbSession) -> LeaderboardOut:
    rows = (
        await db.execute(
            select(Player.username, Player.best_score)
            .where(Player.best_score > 0)
            .order_by(Player.best_score.desc(), Player.created_at.asc(), Player.id.asc())
            .limit(LEADERBOARD_SIZE)
        )
    ).all()
    entries = [
        LeaderboardEntry(rank=rank, username=username, best_score=best_score)
        for rank, (username, best_score) in enumerate(rows, start=1)
    ]
    return LeaderboardOut(entries=entries)
