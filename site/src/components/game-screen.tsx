import { ACTIVE, BOARD, COLS, GHOST, LEVEL, LINES, NEXT, ROWS, SCORE } from "@/lib/board-data";
import { cn } from "@/lib/cn";
import { PIECE_LETTERS, pieceShape } from "@/lib/pieces";

/** The real game screen, rebuilt in CSS from a dumped board state. */
export function GameScreen({ light = false }: { light?: boolean }) {
  const occupied = new Map<string, string>();
  BOARD.forEach((row, y) =>
    row.forEach((value, x) => {
      if (value > 0) occupied.set(`${x},${y}`, PIECE_LETTERS[value - 1]);
    }),
  );
  for (const [x, y] of GHOST) {
    if (!occupied.has(`${x},${y}`)) occupied.set(`${x},${y}`, "ghost");
  }
  for (const [x, y] of ACTIVE.cells) {
    occupied.set(`${x},${y}`, PIECE_LETTERS[ACTIVE.type]);
  }

  const next = pieceShape(NEXT + 1);
  const nextGrid: (string | null)[][] = Array.from({ length: next.rows }, () =>
    Array.from({ length: next.cols }, () => null),
  );
  for (const [x, y] of next.cells) nextGrid[y][x] = PIECE_LETTERS[NEXT];

  return (
    <div className={cn("flex flex-col gap-3 px-3 pb-5", light && "light")}>
      <div className="flex items-end justify-between gap-2 px-1">
        <div>
          <div className="text-[1.35rem] font-semibold leading-none tabular-nums">{SCORE}</div>
          <div className="mt-1 text-[10px] tracking-[0.2em] text-text-faint">SCORE</div>
        </div>
        <div className="flex items-end gap-4">
          <Stat label="LEVEL" value={LEVEL} />
          <Stat label="LINES" value={LINES} />
        </div>
        <div>
          <NextPreview grid={nextGrid} />
          <div className="mt-1 text-right text-[10px] tracking-[0.2em] text-text-faint">NEXT</div>
        </div>
      </div>

      <div
        className="grid gap-[2px] rounded-cell bg-background p-1"
        style={{ gridTemplateColumns: `repeat(${COLS}, minmax(0, 1fr))` }}
        aria-hidden
      >
        {Array.from({ length: ROWS * COLS }, (_, i) => {
          const x = i % COLS;
          const y = Math.floor(i / COLS);
          const piece = occupied.get(`${x},${y}`);
          if (!piece) return <span key={i} className="aspect-square rounded-cell bg-board-cell" />;
          if (piece === "ghost")
            return (
              <span key={i} className="aspect-square rounded-cell border border-line-strong" />
            );
          return (
            <span
              key={i}
              className={cn(
                "aspect-square rounded-cell",
                ACTIVE.cells.some((cell) => cell[0] === x && cell[1] === y) &&
                  "outline outline-1 outline-text/70",
              )}
              style={{ background: `var(--piece-${piece})` }}
            />
          );
        })}
      </div>

      <Controls />
    </div>
  );
}

function Stat({ label, value }: { label: string; value: number }) {
  return (
    <div className="text-right">
      <div className="text-sm leading-none tabular-nums">{value}</div>
      <div className="mt-1 text-[10px] tracking-[0.2em] text-text-faint">{label}</div>
    </div>
  );
}

function NextPreview({ grid }: { grid: (string | null)[][] }) {
  return (
    <div
      className="grid gap-[2px] rounded-cell bg-board-cell p-1.5"
      style={{ gridTemplateColumns: `repeat(${grid[0].length}, minmax(0, 1fr))` }}
      aria-hidden
    >
      {grid.flatMap((row, y) =>
        row.map((piece, x) =>
          piece ? (
            <span
              key={`${x},${y}`}
              className="aspect-square w-2.5 rounded-[2px]"
              style={{ background: `var(--piece-${piece})` }}
            />
          ) : (
            <span key={`${x},${y}`} className="aspect-square w-2.5" />
          ),
        ),
      )}
    </div>
  );
}

const BUTTONS = [
  {
    label: "Left",
    path: "M15 18l-6-6 6-6",
  },
  {
    label: "Right",
    path: "M9 6l6 6-6 6",
  },
  {
    label: "Rotate",
    path: "M21 12a9 9 0 1 1-3-6.7M21 3v6h-6",
  },
  {
    label: "Hard drop",
    path: "M12 3v12m0 0l-5-5m5 5l5-5M5 21h14",
  },
];

function Controls() {
  return (
    <div className="grid grid-cols-4 gap-2" aria-hidden>
      {BUTTONS.map((b) => (
        <span
          key={b.label}
          className="flex h-10 items-center justify-center rounded-cell border border-line bg-surface-2"
        >
          <svg
            viewBox="0 0 24 24"
            className="h-4 w-4"
            fill="none"
            stroke="currentColor"
            strokeWidth="2"
          >
            <path d={b.path} strokeLinecap="round" strokeLinejoin="round" />
          </svg>
        </span>
      ))}
    </div>
  );
}
