"""Server-side plausibility limits for synced stats.

These mirror game/scripts/game_config.gd (LINE_POINTS, COMBO_BONUS,
BACK_TO_BACK_MULTIPLIER, MAX_START_LEVEL, LINES_PER_LEVEL). Change them there
and here together.
"""

from typing import Final

# Worst case per line: a back-to-back tetris (800 * 1.5 points / 4 lines).
MAX_POINTS_PER_LINE: Final = 300
# Combo bonus grows linearly within a chain (50 * combo * level): across n
# clears the chain adds about 25 * n^2 at level 1. Generous on purpose: the
# cap only needs to reject fabricated scores, not good play.
MAX_COMBO_PER_LINE_SQUARED: Final = 25
MAX_START_LEVEL: Final = 10
LINES_PER_LEVEL: Final = 10

# Modes. Sprint clears exactly SPRINT_GOAL_LINES lines and races the clock;
# Ultra is a two-minute score attack, so its line count stays plausible for
# two minutes of play.
CATEGORIES: Final = ("marathon", "sprint", "ultra", "daily")
SPRINT_GOAL_LINES: Final = 40
ULTRA_TIME_LIMIT: Final = 120
ULTRA_MAX_LINES: Final = 80
# A sprint under fifteen seconds or over half an hour cannot be real.
SPRINT_MIN_DURATION_MS: Final = 15_000
SPRINT_MAX_DURATION_MS: Final = 30 * 60_000


def max_plausible_score(total_lines: int, category: str = "marathon") -> int:
    """Upper bound on a category's score given its lifetime lines.

    Marathon, daily, and ultra all score like marathon runs; ultra callers
    cap `total_lines` at ULTRA_MAX_LINES first.
    """
    level_factor = MAX_START_LEVEL + total_lines // LINES_PER_LEVEL
    raw = MAX_POINTS_PER_LINE * total_lines + MAX_COMBO_PER_LINE_SQUARED * total_lines * total_lines
    return raw * level_factor
