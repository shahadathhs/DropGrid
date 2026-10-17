/**
 * Numbers the how-to-play page prints. Each constant mirrors a value in
 * game/scripts/game_config.gd (names kept); the fall interval is the formula
 * in game_controller.gd, GameController.fall_interval().
 */

/** GameConfig.LINE_POINTS: points for clearing 0..4 lines at once, times the level. */
export const LINE_POINTS = [0, 100, 300, 500, 800] as const;
/** GameConfig.LINES_PER_LEVEL. */
export const LINES_PER_LEVEL = 10;
/** GameConfig.MAX_START_LEVEL. */
export const MAX_START_LEVEL = 10;
/** GameConfig.BASE_FALL_INTERVAL, seconds between automatic steps at level 1. */
export const BASE_FALL_INTERVAL = 0.8;
/** GameConfig.FALL_SPEEDUP, multiplier per level above 1. */
export const FALL_SPEEDUP = 0.85;
/** GameConfig.MIN_FALL_INTERVAL, the floor. */
export const MIN_FALL_INTERVAL = 0.08;
/** GameConfig.SOFT_DROP_INTERVAL. */
export const SOFT_DROP_INTERVAL = 0.04;
/** GameConfig.MOVE_REPEAT_DELAY and MOVE_REPEAT_INTERVAL. */
export const MOVE_REPEAT_DELAY = 0.16;
export const MOVE_REPEAT_INTERVAL = 0.05;
/** GameConfig.COMBO_BONUS: points per combo step, times the level. */
export const COMBO_BONUS = 50;
/** GameConfig.BACK_TO_BACK_MULTIPLIER. */
export const BACK_TO_BACK_MULTIPLIER = 1.5;
/** GameConfig.LOCK_DELAY (seconds) and MAX_LOCK_RESETS. */
export const LOCK_DELAY = 0.5;
export const MAX_LOCK_RESETS = 15;
/** GameConfig.NEXT_QUEUE_SIZE. */
export const NEXT_QUEUE_SIZE = 3;

/** GameController.fall_interval(level): max(MIN, BASE * SPEEDUP^(level - 1)). */
export function fallInterval(level: number): number {
  return Math.max(MIN_FALL_INTERVAL, BASE_FALL_INTERVAL * FALL_SPEEDUP ** (level - 1));
}

/** GameController.points_for_lines(count, level). */
export function pointsForLines(count: number, level: number): number {
  return LINE_POINTS[count] * level;
}

/** Lifetime lines that open a start level: 10 × (level − 1) (levels_screen.gd). */
export function linesToReach(level: number): number {
  return LINES_PER_LEVEL * (level - 1);
}
