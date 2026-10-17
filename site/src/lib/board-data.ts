// A real, reachable game state, produced by driving the actual GameController
// (BoardModel, PieceBag, move/rotate/hold/hard_drop) headless with seed
// 1150 and a noisy greedy placer: 35 pieces placed, a few holds, play time
// advanced with GameController.advance. It is the state right after the
// 36th spawn. The active piece, hard-dropped where it stands, completes rows
// 15 and 16: the hero animation plays that clear. Reproduced by replaying seed 1150 to
// piece 35 through the same public GameController API (not part of the repo).
// Do not edit by hand; do not "improve" the numbers.

export const COLS = 10;
export const ROWS = 20;
export const SCORE = 1150;
export const LINES = 9;
export const LEVEL = 1;
export const HOLD = 5;
export const QUEUE: number[] = [6, 2, 5];

function clock(ms: number): string {
  const total = Math.floor(ms / 1000);
  return `${Math.floor(total / 60)}:${String(total % 60).padStart(2, "0")}`;
}

export const ELAPSED = clock(46250);

/** 20 rows x 10 cols of piece color indexes (0 = empty, 1..7 = piece). */
export const BOARD: number[][] = [
  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
  [0, 0, 0, 0, 0, 0, 0, 5, 0, 0],
  [2, 2, 4, 0, 0, 0, 5, 5, 3, 0],
  [2, 2, 4, 4, 0, 0, 5, 5, 3, 3],
  [7, 7, 7, 4, 0, 0, 5, 5, 3, 1],
  [7, 5, 1, 1, 0, 4, 5, 6, 6, 1],
  [5, 5, 1, 1, 0, 4, 4, 6, 7, 1],
  [5, 5, 1, 1, 0, 5, 4, 6, 7, 1],
];

export const ACTIVE = {
  cells: [
    [4, 0],
    [5, 0],
    [4, 1],
    [5, 1],
  ],
  type: 1,
} as const;

export const GHOST = [
  [4, 15],
  [5, 15],
  [4, 16],
  [5, 16],
] as const;
