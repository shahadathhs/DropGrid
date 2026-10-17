/**
 * A piece above a stack, and its ghost where it will land. Built from the
 * screen's own block classes: ink frame for the piece, an empty frame in the
 * piece color for the ghost, framed fills for locked blocks.
 */
const COLS = 7;
const ROWS = 6;

/** Locked blocks: row 5 is full except column 3, so the piece rests on its ends. */
const LOCKED: { x: number; y: number; letter: string }[] = [
  { x: 0, y: 5, letter: "j" },
  { x: 1, y: 5, letter: "l" },
  { x: 2, y: 5, letter: "s" },
  { x: 4, y: 5, letter: "z" },
  { x: 5, y: 5, letter: "i" },
  { x: 6, y: 5, letter: "o" },
];

/** T piece, spawn orientation, offset 2 columns: cells from piece_data.gd. */
const ACTIVE: [number, number][] = [
  [3, 0],
  [2, 1],
  [3, 1],
  [4, 1],
];
const GHOST: [number, number][] = [
  [3, 3],
  [2, 4],
  [3, 4],
  [4, 4],
];

export function GhostDiagram() {
  const lockedAt = new Map(LOCKED.map((b) => [`${b.x},${b.y}`, b.letter]));
  const ghostAt = new Set(GHOST.map(([x, y]) => `${x},${y}`));
  return (
    <div className="demo-board" style={{ ["--cols" as string]: COLS }} aria-hidden>
      {Array.from({ length: COLS * ROWS }, (_, i) => {
        const key = `${i % COLS},${Math.floor(i / COLS)}`;
        const locked = lockedAt.get(key);
        if (locked) return <span key={i} className={`tile blk blk--${locked}`} />;
        if (ghostAt.has(key)) return <span key={i} className="tile blk blk--ghost blk--t" />;
        return <span key={i} className="tile" />;
      })}
      <div className="active-piece">
        {ACTIVE.map(([x, y]) => (
          <span
            key={`${x},${y}`}
            className="active-cell blk blk--t"
            style={{ ["--x" as string]: x, ["--y" as string]: y }}
          />
        ))}
      </div>
    </div>
  );
}
