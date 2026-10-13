from sqlalchemy import Integer, String
from sqlalchemy.orm import Mapped, mapped_column

from models.base import Base


class Player(Base):
    """Account + synced stats. One row per player (docs section 9 data model).

    email and username are stored lowercase (see core/validation.py), so the
    unique indexes are case-insensitive.
    """

    __tablename__ = "players"

    email: Mapped[str] = mapped_column(String(320), unique=True, index=True)
    username: Mapped[str] = mapped_column(String(20), unique=True, index=True)
    password_hash: Mapped[str] = mapped_column(String(100))
    # Bumped on password change; tokens carry it as the "pv" claim.
    password_version: Mapped[int] = mapped_column(Integer, default=0, server_default="0")

    # Monotonic counters; the sync merge rule stores max(server, client).
    best_score: Mapped[int] = mapped_column(Integer, default=0, server_default="0", index=True)
    total_lines: Mapped[int] = mapped_column(Integer, default=0, server_default="0")
    games_played: Mapped[int] = mapped_column(Integer, default=0, server_default="0")
