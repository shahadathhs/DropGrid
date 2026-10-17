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


@router.post(
    "/sync",
    response_model=PlayerOut,
    summary="Push your stats",
    responses={
        401: {"description": "Missing or invalid access token"},
        422: {
            "description": "Implausible stats (progress without games, or score too high for lines)"
        },
    },
)
async def sync(data: SyncIn, player: CurrentPlayer, db: DbSession) -> PlayerOut:
    """Merge the client's stats into the player's record and return the result.

    Each stat merges as `max(server, client)`, so replaying an older state
    can never lower the stored values. The row is locked for the merge so
    two devices syncing at once cannot overwrite each other. Stats that
    break the server's plausibility rules are rejected with 422 instead of
    being stored.
    """
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


@router.get(
    "/leaderboard",
    response_model=LeaderboardOut,
    summary="Top 50 players",
    responses={200: {"description": "The top 50 by best score; empty until someone scores"}},
)
async def leaderboard(db: DbSession) -> LeaderboardOut:
    """Return the top 50 players by best score, highest first.

    Ties break by earliest signup. Players with a best score of 0 are not
    listed. No auth required.
    """
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
