import { PIECE_LETTERS } from "@/lib/pieces";

/**
 * The wordmark as blocks, from game/scripts/wordmark.gd: each letter a 3x5
 * pattern in one piece color (cycling I, O, T, S, Z, J, L, I), two rows
 * "DROP" over "GRID", one cell between letters and rows. 15 x 11 cells.
 */
const GLYPHS: Record<string, string[]> = {
  D: ["110", "101", "101", "101", "110"],
  R: ["110", "101", "110", "101", "101"],
  O: ["111", "101", "101", "101", "111"],
  P: ["110", "101", "110", "100", "100"],
  G: ["011", "100", "101", "101", "011"],
  I: ["111", "010", "010", "010", "111"],
};

export const WORDMARK_COLS = 15;
export const WORDMARK_ROWS = 11;

export type WordmarkBlock = { x: number; y: number; piece: (typeof PIECE_LETTERS)[number] };

export function wordmarkBlocks(): WordmarkBlock[] {
  const blocks: WordmarkBlock[] = [];
  let index = 0;
  ["DROP", "GRID"].forEach((word, row) => {
    word.split("").forEach((ch, letter) => {
      const piece = PIECE_LETTERS[index % 7];
      index += 1;
      GLYPHS[ch].forEach((line, y) =>
        line.split("").forEach((bit, x) => {
          if (bit === "1") blocks.push({ x: letter * 4 + x, y: row * 6 + y, piece });
        }),
      );
    });
  });
  return blocks;
}
