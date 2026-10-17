from sqlalchemy import ForeignKey, Integer, String, UniqueConstraint
from sqlalchemy.orm import Mapped, mapped_column

from models.base import Base


class Score(Base):
    """One player's best in one leaderboard category (see GameMode).

    category is one of marathon/sprint/ultra/daily. period_key is the UTC date
    (YYYY-MM-DD) for daily bests and NULL for the all-time boards. Sprint
    stores duration_ms and ranks ascending (lower is better); every other
    category ranks by score descending.
    """

    __tablename__ = "scores"
    __table_args__ = (
        UniqueConstraint(
            "player_id", "category", "period_key", name="uq_scores_player_category_period"
        ),
    )

    player_id: Mapped[str] = mapped_column(
        ForeignKey("players.id", ondelete="CASCADE"), index=True
    )
    category: Mapped[str] = mapped_column(String(16), index=True)
    period_key: Mapped[str | None] = mapped_column(String(10))
    score: Mapped[int] = mapped_column(Integer, default=0, server_default="0")
    lines: Mapped[int] = mapped_column(Integer, default=0, server_default="0")
    duration_ms: Mapped[int | None] = mapped_column(Integer)
