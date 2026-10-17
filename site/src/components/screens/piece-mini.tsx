import { PIECE_LETTERS, pieceShape } from "@/lib/pieces";

/** One preview slot (hold or a next-queue entry): a piece on its own small tile. */
export function PieceMini({ piece, cell = 20 }: { piece: number | null; cell?: number }) {
  const shape = piece === null ? null : pieceShape(piece + 1);
  return (
    <div
      className="mini"
      style={{
        ["--p" as string]: `calc(var(--u) * ${cell})`,
        gridTemplateColumns: `repeat(4, var(--p))`,
        gridAutoRows: "var(--p)",
        width: `calc(var(--u) * ${cell * 4 + 16})`,
        height: `calc(var(--u) * ${cell * 2 + 16})`,
      }}
    >
      {shape
        ? shape.cells.map(([x, y]) => (
            <span
              key={`${x},${y}`}
              className={`tile blk blk--${PIECE_LETTERS[piece as number]}`}
              style={{ gridColumn: x + 1, gridRow: y + 1 }}
            />
          ))
        : null}
    </div>
  );
}
