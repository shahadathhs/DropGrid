import { Fragment } from "react";

/**
 * The lock delay as two bars. Top: a piece lands and the timer runs out. Below:
 * each successful move or rotation sends the timer back to the start. Widths are
 * drawn for shape only; the numbers are in the text beside it.
 */
const RUNS = [62, 38, 80];

export function LockTimeline() {
  return (
    <div className="flex w-full max-w-xl flex-col gap-5 text-xs text-text-muted" aria-hidden>
      <div className="flex flex-col gap-2">
        <div className="flex justify-between">
          <span>Lands</span>
          <span>Locks</span>
        </div>
        <div className="track">
          <span className="fill" style={{ flex: "1 1 0" }} />
        </div>
      </div>
      <div className="flex flex-col gap-2">
        <div className="flex justify-between">
          <span>Lands</span>
          <span>Moves, restarts, locks</span>
        </div>
        <div className="track">
          {RUNS.map((w, i) => (
            <Fragment key={i}>
              <span className="fill" style={{ flex: `${w} 1 0` }} />
              <span className="tick" />
            </Fragment>
          ))}
          <span className="fill" style={{ flex: "100 1 0" }} />
        </div>
      </div>
    </div>
  );
}
