from pydantic import BaseModel


class SyncIn(BaseModel):
    best_score: int
    total_lines: int
    games_played: int


class SyncOut(BaseModel):
    """Merged server state, written back to the client's local save."""

    best_score: int
    total_lines: int
    games_played: int


class LeaderboardEntry(BaseModel):
    rank: int
    username: str
    best_score: int


class LeaderboardOut(BaseModel):
    entries: list[LeaderboardEntry]
