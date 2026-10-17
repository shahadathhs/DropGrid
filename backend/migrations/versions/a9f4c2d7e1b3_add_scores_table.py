"""add scores table for category leaderboards

Revision ID: a9f4c2d7e1b3
Revises: 326776dc5a61
Create Date: 2026-10-17 10:00:00.000000

"""

from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op

# revision identifiers, used by Alembic.
revision: str = "a9f4c2d7e1b3"
down_revision: str | Sequence[str] | None = "326776dc5a61"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    """Upgrade schema."""
    op.create_table(
        "scores",
        sa.Column("player_id", sa.Uuid(), nullable=False),
        sa.Column("category", sa.String(length=16), nullable=False),
        sa.Column("period_key", sa.String(length=10), nullable=True),
        sa.Column("score", sa.Integer(), server_default="0", nullable=False),
        sa.Column("lines", sa.Integer(), server_default="0", nullable=False),
        sa.Column("duration_ms", sa.Integer(), nullable=True),
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
        sa.ForeignKeyConstraint(["player_id"], ["players.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint(
            "player_id",
            "category",
            "period_key",
            name="uq_scores_player_category_period",
        ),
    )
    op.create_index(op.f("ix_scores_player_id"), "scores", ["player_id"], unique=False)
    op.create_index(op.f("ix_scores_category"), "scores", ["category"], unique=False)


def downgrade() -> None:
    """Downgrade schema."""
    op.drop_index(op.f("ix_scores_category"), table_name="scores")
    op.drop_index(op.f("ix_scores_player_id"), table_name="scores")
    op.drop_table("scores")
