"""Server-side plausibility limits for synced stats.

These mirror game/scripts/game_config.gd (LINE_POINTS, MAX_START_LEVEL,
LINES_PER_LEVEL). Change them there and here together.
"""

from typing import Final

MAX_POINTS_PER_LINE: Final = 800 // 4  # LINE_POINTS: a 4-line clear scores 800
MAX_START_LEVEL: Final = 10
LINES_PER_LEVEL: Final = 10


def max_plausible_score(total_lines: int) -> int:
    """Upper bound on best_score given lifetime lines.

    A single game has at most total_lines lines, scores at most 200 points per
    line times the level, and the level is at most the start level plus one per
    LINES_PER_LEVEL lines.
    """
    return MAX_POINTS_PER_LINE * total_lines * (MAX_START_LEVEL + total_lines // LINES_PER_LEVEL)
