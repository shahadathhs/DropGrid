/**
 * What each mode does, read from game/scripts/game_mode.gd, game_controller.gd,
 * game_config.gd, mode_picker.gd and game.gd. Short names for the lists on
 * /modes; the one-line rule and the leaderboard line live in lib/modes.ts.
 */
export type ModeId = "marathon" | "sprint" | "ultra" | "daily" | "zen";

export type ModeFacts = {
  /** What the run is, as the game states it. */
  goal: string;
  /** What ends the run. */
  ends: string;
  /** The TIME readout in the HUD. */
  clock: string;
  /** The level the run begins at. */
  start: string;
};

/** GameConfig.SPRINT_GOAL_LINES and ULTRA_TIME_LIMIT (seconds). */
export const SPRINT_GOAL_LINES = 40;
export const ULTRA_TIME_LIMIT = 120;

/** The HUD clock at the start of an Ultra run: mm:ss of ULTRA_TIME_LIMIT. */
export const ULTRA_CLOCK = `${Math.floor(ULTRA_TIME_LIMIT / 60)}:${String(ULTRA_TIME_LIMIT % 60).padStart(2, "0")}`;

export const modeFacts: Record<ModeId, ModeFacts> = {
  marathon: {
    goal: "No goal. Clear lines, level up, last as long as you can.",
    ends: "A new piece cannot spawn. The results screen reads Game over.",
    clock: "Counts up from 0:00.",
    start:
      "Any level from 1 to 10 that you have unlocked. Level N opens at 10 × (N − 1) lifetime lines.",
  },
  sprint: {
    goal: `Clear ${SPRINT_GOAL_LINES} lines.`,
    ends: `The run ends as a win once ${SPRINT_GOAL_LINES} lines are cleared. The results screen reads Finished. A top-out still ends it as Game over.`,
    clock: "Counts up from 0:00. The clock is the result.",
    start: "Level 1. The level still rises every 10 lines.",
  },
  ultra: {
    goal: "Score as much as you can before the clock runs out.",
    ends: "The clock reaches 0:00, or a new piece cannot spawn. The results screen reads Game over.",
    clock: `Counts down from ${ULTRA_CLOCK}.`,
    start: "Level 1. The level still rises every 10 lines.",
  },
  daily: {
    goal: "Marathon rules on a piece order set by the UTC day. Everyone gets the same order on the same day.",
    ends: "A new piece cannot spawn. The results screen reads Game over.",
    clock: "Counts up from 0:00.",
    start: "Level 1.",
  },
  zen: {
    goal: "No goal. Play without pressure.",
    ends: "Nothing ends it. When a new piece cannot spawn, the board is cleared and play continues. Score and lines keep counting. Pause, then End run, to stop.",
    clock: "Counts up from 0:00.",
    start: "Level 1.",
  },
};
