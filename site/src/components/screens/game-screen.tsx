import { Fragment } from "react";
import {
  ACTIVE,
  BOARD,
  COLS,
  ELAPSED,
  GHOST,
  HOLD,
  LEVEL,
  LINES,
  QUEUE,
  ROWS,
  SCORE,
} from "@/lib/board-data";
import { CONTROL_ROW } from "@/lib/controls";
import { thousands } from "@/lib/format";
import type { ModeId } from "@/lib/mode-rules";
import { ULTRA_CLOCK } from "@/lib/mode-rules";
import { PIECE_LETTERS } from "@/lib/pieces";
import { ControlGlyph } from "@/components/screens/control-glyph";
import { PauseButton } from "@/components/screens/pause-button";
import { PieceMini } from "@/components/screens/piece-mini";
import { ScreenShell } from "@/components/screens/screen-shell";

/** Cells the active piece falls from its spawn to its ghost. */
const FALL = GHOST[0][1] - ACTIVE.cells[0][1];

/** Rows the active piece completes when it lands on its ghost (a real clear). */
function completedRows(): number[] {
  const filled = new Set(GHOST.map(([x, y]) => `${x},${y}`));
  return Array.from({ length: ROWS }, (_, y) => y).filter((y) =>
    Array.from({ length: COLS }, (_, x) => x).every(
      (x) => BOARD[y][x] > 0 || filled.has(`${x},${y}`),
    ),
  );
}

/**
 * The play screen, rebuilt from a real dumped game state (lib/board-data.ts):
 * the HUD row (hold, score, level, lines, time, next queue, pause) and the
 * control row, as game.tscn lays them out.
 * `animated` lets the page play the move with the scroll position (motion.css):
 * the active piece falls cell by cell to its ghost, the rows it completes fade
 * out, and the cells above drop by the number of cleared rows. Without it, or
 * without scroll-timeline support, everything stays as the dump left it.
 * `mode` shows that mode's HUD (only Ultra differs: its clock counts down from
 * 2:00).
 */
export function GameScreen({
  light = false,
  animated = false,
  mode,
}: {
  light?: boolean;
  animated?: boolean;
  mode?: ModeId;
}) {
  const letter = PIECE_LETTERS[ACTIVE.type];
  const cleared = completedRows();
  /** The motion class of a block that ends in row `y`: it fades with its row or drops. */
  const motion = (y: number) => {
    if (!animated) return "";
    if (cleared.includes(y)) return " vanish";
    const drop = cleared.filter((row) => row > y).length;
    return drop > 0 ? ` settle settle-${drop}` : "";
  };

  return (
    <ScreenShell light={light}>
      <div className="hud">
        <div className="hud-col">
          <div className="hud-label">HOLD</div>
          <PieceMini piece={HOLD >= 0 ? HOLD : null} cell={10} />
        </div>
        <div className="hud-col hud-col--score">
          <div className="hud-label">SCORE</div>
          <div className="hud-score">{thousands(SCORE)}</div>
        </div>
        <div className="hud-col">
          <div className="hud-label">LEVEL</div>
          <div className="hud-value">{LEVEL}</div>
        </div>
        <div className="hud-col">
          <div className="hud-label">LINES</div>
          <div className="hud-value">{LINES}</div>
        </div>
        <div className="hud-col">
          <div className="hud-label">TIME</div>
          <div className="hud-value">{mode === "ultra" ? ULTRA_CLOCK : ELAPSED}</div>
        </div>
        <div className="hud-col">
          <div className="hud-label">NEXT</div>
          <div className="hud-queue">
            {QUEUE.map((piece, i) => (
              <PieceMini key={i} piece={piece} cell={10} />
            ))}
          </div>
        </div>
        <PauseButton />
      </div>

      <div className="board">
        {Array.from({ length: ROWS * COLS }, (_, i) => (
          <span key={i} className="tile" />
        ))}
        <div className="layer">
          {BOARD.flatMap((row, y) =>
            row.map((value, x) =>
              value > 0 ? (
                <span
                  key={`${x},${y}`}
                  className={`cell-abs blk blk--${PIECE_LETTERS[value - 1]}${motion(y)}`}
                  style={{ ["--x" as string]: x, ["--y" as string]: y }}
                />
              ) : null,
            ),
          )}
          {GHOST.map(([x, y]) => (
            <span
              key={`g${x},${y}`}
              className={`cell-abs blk blk--ghost blk--${letter}${animated ? " ghost-gone" : ""}`}
              style={{ ["--x" as string]: x, ["--y" as string]: y }}
            />
          ))}
        </div>
        <div
          className={animated ? "layer fall-on-scroll" : "layer"}
          style={{ ["--fall" as string]: FALL, ["--levels" as string]: FALL + 1 }}
        >
          {ACTIVE.cells.map(([x, y], i) => (
            <span
              key={`${x},${y}`}
              className={`cell-abs active-cell blk blk--${letter}${motion(GHOST[i][1])}`}
              style={{ ["--x" as string]: x, ["--y" as string]: y }}
            />
          ))}
        </div>
      </div>

      <div className="controls">
        {CONTROL_ROW.map((c) => (
          <Fragment key={c.id}>
            {c.drop ? <span className="ctl-gap" /> : null}
            <ControlGlyph control={c} />
          </Fragment>
        ))}
      </div>
    </ScreenShell>
  );
}
