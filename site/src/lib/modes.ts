/**
 * The five modes, mirrored from game/scripts/game_mode.gd (names, taglines) and
 * docs/README_GAMEPLAY_FEATURES.md section 3c (rules, leaderboard category).
 */
export type Mode = {
  id: string;
  name: string;
  /** The one-line description the mode picker shows. */
  tagline: string;
  /** What the run is, in a few words. */
  rule: string;
  /** What the leaderboard ranks, or none. */
  board: string;
};

export const modes: Mode[] = [
  {
    id: "marathon",
    name: "Marathon",
    tagline: "Clear lines, level up, survive.",
    rule: "Classic survival. Pick any unlocked start level.",
    board: "Best score, all time",
  },
  {
    id: "sprint",
    name: "Sprint",
    tagline: "Clear 40 lines as fast as you can.",
    rule: "Clear 40 lines. The run ends as a win.",
    board: "Time to 40, lower is better",
  },
  {
    id: "ultra",
    name: "Ultra",
    tagline: "Two minutes. Best score wins.",
    rule: "A two-minute score attack.",
    board: "Best score, all time",
  },
  {
    id: "daily",
    name: "Daily",
    tagline: "Today's fixed piece order. Everyone plays the same.",
    rule: "Marathon rules on a piece order set by the UTC date.",
    board: "Best score of the day, resets daily",
  },
  {
    id: "zen",
    name: "Zen",
    tagline: "No game over. The board clears itself.",
    rule: "A full board sheds everything and play continues.",
    board: "No leaderboard",
  },
];
