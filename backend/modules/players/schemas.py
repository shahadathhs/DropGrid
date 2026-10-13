import uuid

from pydantic import BaseModel, ConfigDict

from core.validation import Username


class PlayerOut(BaseModel):
    """Profile returned by /players/me, PATCH /players/me and /sync."""

    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    email: str
    username: str
    best_score: int
    total_lines: int
    games_played: int


class PlayerUpdateIn(BaseModel):
    username: Username
