import { readFile } from "node:fs/promises";
import { join } from "node:path";
import { ImageResponse } from "next/og";
import { PIECE_LETTERS } from "@/lib/pieces";
import { grounds, pieceColors } from "@/lib/tokens";
import { wordmarkBlocks } from "@/lib/wordmark-blocks";

export const alt = "DropGrid, a falling-block puzzle for Android";
export const size = { width: 1200, height: 630 };
export const contentType = "image/png";

/** The fill pulled 32% toward black, the game's block frame (cell_style.gd). */
function frame(hex: string): string {
  const n = parseInt(hex.slice(1), 16);
  const k = 0.68;
  const c = [(n >> 16) & 255, (n >> 8) & 255, n & 255].map((v) => Math.round(v * k));
  return `rgb(${c[0]}, ${c[1]}, ${c[2]})`;
}

export default async function Image() {
  const font = await readFile(join(process.cwd(), "src/fonts/DepartureMono-Regular.otf"));
  const g = grounds.dark;
  const cell = 44;
  const blocks = wordmarkBlocks().map((b) => ({
    ...b,
    fill: pieceColors[PIECE_LETTERS.indexOf(b.piece)],
  }));

  return new ImageResponse(
    <div
      style={{
        width: "100%",
        height: "100%",
        display: "flex",
        flexDirection: "column",
        justifyContent: "space-between",
        padding: 72,
        background: g.background,
        color: g.ink,
        fontFamily: "Departure Mono",
      }}
    >
      <div style={{ display: "flex", position: "relative", width: cell * 15, height: cell * 11 }}>
        {blocks.map((b) => (
          <div
            key={`${b.x},${b.y}`}
            style={{
              position: "absolute",
              left: b.x * cell + cell / 16,
              top: b.y * cell + cell / 16,
              width: cell * 0.875,
              height: cell * 0.875,
              background: b.fill,
              border: `${cell / 8}px solid ${frame(b.fill)}`,
              boxSizing: "border-box",
            }}
          />
        ))}
      </div>
      <div style={{ display: "flex", fontSize: 40 }}>A falling-block puzzle for Android.</div>
    </div>,
    { ...size, fonts: [{ name: "Departure Mono", data: font, style: "normal", weight: 400 }] },
  );
}
