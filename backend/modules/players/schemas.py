from pydantic import BaseModel


class PlayerOut(BaseModel):
    username: str
    best_score: int
    total_lines: int
    games_played: int
