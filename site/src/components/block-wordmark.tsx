import { wordmarkBlocks } from "@/lib/wordmark-blocks";

/**
 * The wordmark drawn from blocks, as the game draws it (lib/wordmark-blocks.ts).
 * Decorative; the name is in the surrounding text. `cell` is one cell as a CSS length.
 */
export function BlockWordmark({ cell }: { cell: string }) {
  return (
    <div
      aria-hidden
      className="blockmark"
      style={{
        ["--p" as string]: cell,
        gridTemplateColumns: "repeat(15, var(--p))",
        gridAutoRows: "var(--p)",
      }}
    >
      {wordmarkBlocks().map((b) => (
        <span
          key={`${b.x},${b.y}`}
          className={`tile blk blk--${b.piece}`}
          style={{ gridColumn: b.x + 1, gridRow: b.y + 1 }}
        />
      ))}
    </div>
  );
}
