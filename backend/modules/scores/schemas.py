from typing import Annotated

from pydantic import BaseModel, Field

# Stats are monotonic counters; the cap keeps values inside a 32-bit-safe range.
Stat = Annotated[int, Field(ge=0, le=2_000_000_000)]


class SyncIn(BaseModel):
    best_score: Stat
    total_lines: Stat
    games_played: Stat


class LeaderboardEntry(BaseModel):
    rank: int
    username: str
    best_score: int


class LeaderboardOut(BaseModel):
    entries: list[LeaderboardEntry]
