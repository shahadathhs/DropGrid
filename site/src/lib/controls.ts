/**
 * The touch buttons under the board. Icon paths are the game's icons
 * (game/assets/icons/*.svg, scene game/scenes/game.tscn) on a 24 x 24 grid.
 * Hold has no icon: the game labels it with the text "HOLD".
 */
export type Control = {
  id: "left" | "right" | "rotate" | "hold" | "soft" | "hard";
  label: string;
  /** SVG path data; absent for Hold, which shows text. */
  d?: string;
  /** Hard drop: apart from the rest, drawn in the signal color. */
  drop?: boolean;
};

export const LEFT: Control = { id: "left", label: "Left", d: "M15 18l-6-6 6-6" };
export const RIGHT: Control = { id: "right", label: "Right", d: "M9 6l6 6-6 6" };
export const ROTATE: Control = {
  id: "rotate",
  label: "Rotate",
  d: "M21 12a9 9 0 1 1-3-6.7M21 3v6h-6",
};
export const HOLD: Control = { id: "hold", label: "Hold" };
export const SOFT: Control = {
  id: "soft",
  label: "Soft drop",
  d: "M12 5v14m0 0l-5-5m5 5l5-5",
};
export const HARD: Control = {
  id: "hard",
  label: "Hard drop",
  d: "M12 3v12m0 0l-5-5m5 5l5-5M5 21h14",
  drop: true,
};

/** The row as game.tscn orders it, left to right (hard drop after a gap). */
export const CONTROL_ROW: Control[] = [LEFT, RIGHT, ROTATE, HOLD, SOFT, HARD];
