import { BlockWordmark } from "@/components/block-wordmark";
import { ScreenShell } from "@/components/screens/screen-shell";
import { SCORE } from "@/lib/board-data";
import { thousands } from "@/lib/format";
import { PIECE_LETTERS } from "@/lib/pieces";

/**
 * game/scripts/hero_board.gd: [piece type, column, row] on an 8 x 4 mini board.
 * The game's table lists two cells twice: (5, 3) as [5, 5, 3] then [2, 5, 3], and
 * (1, 2) as [4, 1, 2] then [6, 1, 2]. The later entry overdraws the earlier one, so
 * only the later one is kept here (React keys must be unique per cell).
 */
const HERO: [number, number, number][] = [
  [6, 0, 3],
  [6, 1, 3],
  [1, 3, 3],
  [1, 4, 3],
  [2, 6, 2],
  [2, 5, 3],
  [2, 6, 3],
  [5, 4, 2],
  [3, 0, 1],
  [6, 1, 2],
  [6, 2, 2],
  [1, 3, 2],
  [5, 5, 2],
  [4, 5, 1],
  [5, 4, 1],
  [2, 6, 1],
  [3, 6, 0],
  [4, 4, 0],
];

const ROW_ONE = ["Stats", "Levels", "Leaderboard"];
const ROW_TWO = ["Sign in", "Settings"];

/** The main menu: wordmark, hero board, Best, Play, and the link rows. */
export function MenuScreen({ light = false }: { light?: boolean }) {
  return (
    <ScreenShell light={light}>
      <div style={{ flex: 1 }} />
      <div style={{ height: "calc(var(--u) * 430)", display: "flex", alignItems: "center" }}>
        <div style={{ width: "100%" }}>
          <BlockWordmark cell="calc(var(--u) * 39)" />
        </div>
      </div>
      <div
        className="blockmark"
        style={{
          ["--p" as string]: "calc(var(--u) * 34)",
          gridTemplateColumns: "repeat(8, var(--p))",
          gridAutoRows: "var(--p)",
          marginTop: "calc(var(--u) * 12)",
        }}
      >
        {HERO.map(([type, col, row]) => (
          <span
            key={`${col},${row}`}
            className={`tile blk blk--${PIECE_LETTERS[type]}`}
            style={{ gridColumn: col + 1, gridRow: row + 1 }}
          />
        ))}
      </div>
      <div style={{ height: "calc(var(--u) * 36)" }} />
      <div className="scr-caption" style={{ textAlign: "center" }}>
        BEST
      </div>
      <div
        className="scr-display"
        style={{
          textAlign: "center",
          fontSize: "calc(var(--u) * 50)",
          marginTop: "calc(var(--u) * 12)",
        }}
      >
        {thousands(SCORE)}
      </div>
      <div style={{ flex: 1 }} />
      <div className="scr-primary">Play</div>
      <div style={{ marginTop: "calc(var(--u) * 12)" }}>
        <div className="scr-link-row">
          {ROW_ONE.map((label) => (
            <span key={label} className="scr-link">
              {label}
            </span>
          ))}
        </div>
        <div className="scr-link-row">
          {ROW_TWO.map((label) => (
            <span key={label} className="scr-link">
              {label}
            </span>
          ))}
        </div>
      </div>
    </ScreenShell>
  );
}
