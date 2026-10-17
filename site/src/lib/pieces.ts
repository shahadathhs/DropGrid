/**
 * Piece shapes, mirrored from game/scripts/piece_data.gd (rotation 0 only —
 * the hero renders a fixed state, so derived rotations are not needed).
 * Board values are color_index = type + 1.
 */

export const PIECE_LETTERS = ["i", "o", "t", "s", "z", "j", "l"] as const;

/** shape cells for a board color index (1..7), normalized to a bounding box. */
export function pieceShape(colorIndex: number): {
  cols: number;
  rows: number;
  cells: [number, number][];
} {
  const cells = SHAPES[colorIndex - 1];
  const cols = Math.max(...cells.map((c) => c[0])) + 1;
  const rows = Math.max(...cells.map((c) => c[1])) + 1;
  return { cols, rows, cells };
}

const SHAPES: [number, number][][] = [
  [
    [0, 1],
    [1, 1],
    [2, 1],
    [3, 1],
  ], // I
  [
    [1, 0],
    [2, 0],
    [1, 1],
    [2, 1],
  ], // O
  [
    [1, 0],
    [0, 1],
    [1, 1],
    [2, 1],
  ], // T
  [
    [1, 0],
    [2, 0],
    [0, 1],
    [1, 1],
  ], // S
  [
    [0, 0],
    [1, 0],
    [1, 1],
    [2, 1],
  ], // Z
  [
    [0, 0],
    [0, 1],
    [1, 1],
    [2, 1],
  ], // J
  [
    [2, 0],
    [0, 1],
    [1, 1],
    [2, 1],
  ], // L
];
