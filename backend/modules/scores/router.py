from datetime import UTC, datetime

import sqlalchemy as sa
from fastapi import APIRouter, HTTPException, Query
from sqlalchemy import func, select

from core.game_limits import (
    SPRINT_GOAL_LINES,
    SPRINT_MAX_DURATION_MS,
    SPRINT_MIN_DURATION_MS,
    ULTRA_MAX_LINES,
    max_plausible_score,
)
from core.security.deps import CurrentPlayer, DbSession
from models.player import Player
from models.score import Score
from modules.players.schemas import PlayerOut
from modules.scores.schemas import (
    CategoryScoreIn,
    LeaderboardEntry,
    LeaderboardOut,
    RankOut,
    SyncIn,
)

router = APIRouter(tags=["scores"])

LEADERBOARD_SIZE = 50


def _utc_date() -> str:
    return datetime.now(UTC).strftime("%Y-%m-%d")


def _check_category_plausible(entry: CategoryScoreIn) -> None:
    """Reject entries that could not come from a real run (see game_limits)."""
    category = entry.category
    if category == "sprint":
        if entry.lines > SPRINT_GOAL_LINES or entry.score > SPRINT_GOAL_LINES:
            raise HTTPException(422, detail="Implausible sprint: more than 40 lines")
        if entry.duration_ms is None or not (
            SPRINT_MIN_DURATION_MS <= entry.duration_ms <= SPRINT_MAX_DURATION_MS
        ):
            raise HTTPException(422, detail="Implausible sprint duration")
        return
    if category == "ultra" and entry.lines > ULTRA_MAX_LINES:
        raise HTTPException(422, detail="Implausible ultra: too many lines for two minutes")
    if entry.score > max_plausible_score(max(entry.lines, 1), category):
        raise HTTPException(422, detail=f"Implausible {category} score for its line count")
    if category == "daily" and (entry.date is None or entry.date != _utc_date()):
        raise HTTPException(422, detail="Implausible daily: the date must be today (UTC)")


def _check_plausible(data: SyncIn) -> None:
    if data.games_played == 0 and (data.total_lines > 0 or data.best_score > 0):
        raise HTTPException(422, detail="Implausible stats: progress without any games played")
    if data.best_score > max_plausible_score(data.total_lines):
        raise HTTPException(422, detail="Implausible stats: best_score is too high for total_lines")
    for entry in data.categories:
        _check_category_plausible(entry)


async def _merge_category(db: DbSession, player_id, entry: CategoryScoreIn) -> None:
    period_key = entry.date if entry.category == "daily" else None
    existing = (
        await db.execute(
            select(Score).where(
                Score.player_id == player_id,
                Score.category == entry.category,
                Score.period_key == period_key,
            )
        )
    ).scalar_one_or_none()

    if entry.category == "sprint":
        better = (
            existing is None
            or existing.duration_ms is None
            or (entry.duration_ms is not None and entry.duration_ms < existing.duration_ms)
        )
    else:
        better = existing is None or entry.score > existing.score

    if not better:
        return
    if existing is None:
        db.add(
            Score(
                player_id=player_id,
                category=entry.category,
                period_key=period_key,
                score=entry.score,
                lines=entry.lines,
                duration_ms=entry.duration_ms,
            )
        )
    else:
        existing.score = entry.score
        existing.lines = entry.lines
        existing.duration_ms = entry.duration_ms


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
    can never lower the stored values. Category bests merge the same way:
    higher score wins, except sprint where the lower duration wins. The row
    is locked for the merge so two devices syncing at once cannot overwrite
    each other. Stats that break the server's plausibility rules are
    rejected with 422 instead of being stored.
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
    for entry in data.categories:
        await _merge_category(db, player.id, entry)
    await db.commit()
    out = PlayerOut.model_validate(locked)
    rows = (
        await db.execute(
            select(Score).where(
                Score.player_id == player.id, Score.category.in_(("sprint", "ultra", "daily"))
            )
        )
    ).scalars()
    for row in rows:
        best: dict = {"score": row.score, "lines": row.lines}
        if row.category == "sprint":
            best["duration_ms"] = row.duration_ms
        if row.category == "daily":
            best["date"] = row.period_key or ""
        out.category_bests[row.category] = best
    return out


async def _leaderboard_rows(db: DbSession, category: str, period_key: str | None):
    """Rows for a board. Marathon all-time reads players.best_score (the legacy
    column keeps old accounts on the board); every other board reads scores."""
    sprint = category == "sprint"
    if category == "marathon" and period_key is None:
        return (
            await db.execute(
                select(
                    Player.username,
                    Player.best_score,
                    Player.total_lines,
                    sa.literal(None).label("duration_ms"),
                )
                .where(Player.best_score > 0)
                .order_by(Player.best_score.desc(), Player.created_at.asc(), Player.id.asc())
                .limit(LEADERBOARD_SIZE)
            )
        ).all()
    score_col = Score.duration_ms if sprint else Score.score
    order = [score_col.asc()] if sprint else [score_col.desc()]
    positive = Score.duration_ms.is_not(None) if sprint else Score.score > 0
    return (
        await db.execute(
            select(Player.username, Score.score, Score.lines, Score.duration_ms)
            .join(Player, Player.id == Score.player_id)
            .where(Score.category == category, Score.period_key == period_key, positive)
            .order_by(*order, Score.updated_at.asc(), Score.id.asc())
            .limit(LEADERBOARD_SIZE)
        )
    ).all()


@router.get(
    "/leaderboard",
    response_model=LeaderboardOut,
    summary="Top 50 in a category",
    responses={422: {"description": "Unknown category or period"}},
)
async def leaderboard(
    db: DbSession,
    category: str = Query("marathon", pattern="^(marathon|sprint|ultra|daily)$"),
    period: str = Query("all", pattern="^(all|today)$"),
) -> LeaderboardOut:
    """Return the top 50 in one category.

    all-time boards rank by score, highest first; the sprint board ranks by
    duration, lowest first; the daily board needs period=today and ranks
    today's runs on the shared daily seed. No auth required.
    """
    if category == "daily" and period != "today":
        raise HTTPException(422, detail="The daily board only has period=today")
    period_key = _utc_date() if period == "today" else None
    rows = await _leaderboard_rows(db, category, period_key)
    entries = [
        LeaderboardEntry(
            rank=rank, username=username, score=score, lines=lines, duration_ms=duration
        )
        for rank, (username, score, lines, duration) in enumerate(rows, start=1)
    ]
    return LeaderboardOut(category=category, period=period, entries=entries)


@router.get(
    "/leaderboard/rank",
    response_model=RankOut,
    summary="Your rank in a category",
    responses={401: {"description": "Missing or invalid access token"}},
)
async def rank(
    player: CurrentPlayer,
    db: DbSession,
    category: str = Query("marathon", pattern="^(marathon|sprint|ultra|daily)$"),
    period: str = Query("all", pattern="^(all|today)$"),
) -> RankOut:
    """The signed-in player's rank (1-based) even when outside the top 50."""
    if category == "daily" and period != "today":
        raise HTTPException(422, detail="The daily board only has period=today")
    period_key = _utc_date() if period == "today" else None
    out = RankOut(category=category, period=period)
    if category == "marathon" and period == "all":
        best = player.best_score
        if best <= 0:
            return out
        better_count = (
            await db.execute(
                select(func.count()).select_from(Player).where(Player.best_score > best)
            )
        ).scalar_one()
        out.rank = better_count + 1
        out.score = best
        return out
    mine = (
        await db.execute(
            select(Score).where(
                Score.player_id == player.id,
                Score.category == category,
                Score.period_key == period_key,
            )
        )
    ).scalar_one_or_none()
    if mine is None:
        return out
    sprint = category == "sprint"
    mine_value = mine.duration_ms if sprint else mine.score
    if mine_value is None:
        return out
    better_count = (
        await db.execute(
            select(func.count())
            .select_from(Score)
            .where(
                Score.category == category,
                Score.period_key == period_key,
                Score.duration_ms < mine_value if sprint else Score.score > mine_value,
            )
        )
    ).scalar_one()
    out.rank = better_count + 1
    out.score = mine.score
    out.duration_ms = mine.duration_ms
    return out
