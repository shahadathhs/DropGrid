from typing import Annotated

from pydantic import BaseModel, Field

# Stats are monotonic counters; the cap keeps values inside a 32-bit-safe range.
Stat = Annotated[int, Field(ge=0, le=2_000_000_000)]

DATE = Annotated[str, Field(pattern=r"^\d{4}-\d{2}-\d{2}$")]


class CategoryScoreIn(BaseModel):
    """One category best from the client. Marathon is absent on purpose: the
    marathon best is best_score on the player row (legacy column, same data).

    score/lines are the run's numbers; duration_ms is required for sprint
    (lower is better) and ignored elsewhere; date is required for daily and
    must be today's UTC date.
    """

    category: Annotated[str, Field(pattern=r"^(sprint|ultra|daily)$")]
    score: Stat = 0
    lines: Stat = 0
    duration_ms: Annotated[int | None, Field(ge=0, le=3_600_000)] = None
    date: DATE | None = None


class SyncIn(BaseModel):
    best_score: Stat
    total_lines: Stat
    games_played: Stat
    categories: list[CategoryScoreIn] = []


class LeaderboardEntry(BaseModel):
    rank: int
    username: str
    score: int
    lines: int = 0
    duration_ms: int | None = None


class LeaderboardOut(BaseModel):
    category: str
    period: str
    entries: list[LeaderboardEntry]


class RankOut(BaseModel):
    category: str
    period: str
    rank: int | None = None
    score: int | None = None
    duration_ms: int | None = None
