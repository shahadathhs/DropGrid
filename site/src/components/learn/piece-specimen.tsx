import { cn } from "@/lib/cn";
import { PIECE_LETTERS, pieceShape } from "@/lib/pieces";

/** One piece in its spawn orientation on a plain tile plate, in its palette color. */
export function PieceSpecimen({ piece, gray = false }: { piece: number; gray?: boolean }) {
  const letter = PIECE_LETTERS[piece];
  const shape = pieceShape(piece + 1);
  return (
    <div className={cn("spec", gray && "spec--gray")} aria-hidden>
      {shape.cells.map(([x, y]) => (
        <span
          key={`${x},${y}`}
          className={`tile blk blk--${letter}`}
          style={{ gridColumn: x + 1, gridRow: y + 1 }}
        />
      ))}
    </div>
  );
}
