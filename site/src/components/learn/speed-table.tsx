import {
  BASE_FALL_INTERVAL,
  FALL_SPEEDUP,
  MIN_FALL_INTERVAL,
  fallInterval,
  linesToReach,
} from "@/lib/game-rules";

/** Levels listed: every level up to the first one that sits on the floor. */
const lastLevel =
  Math.ceil(Math.log(MIN_FALL_INTERVAL / BASE_FALL_INTERVAL) / Math.log(FALL_SPEEDUP)) + 1;
const levels = Array.from({ length: lastLevel }, (_, i) => i + 1);

/**
 * Seconds between automatic steps per level: the formula in
 * GameController.fall_interval (game_controller.gd) with the constants from
 * game_config.gd, BASE_FALL_INTERVAL 0.8, FALL_SPEEDUP 0.85, MIN_FALL_INTERVAL 0.08.
 * A bar beside each value shows it against level 1.
 */
export function SpeedTable() {
  return (
    <div className="max-w-xl overflow-x-auto">
      <table className="w-full text-xs sm:text-sm">
        <caption className="pb-3 text-left text-text-muted">
          Seconds between automatic steps. {BASE_FALL_INTERVAL} × {FALL_SPEEDUP}
          <sup>level − 1</sup>, never below {MIN_FALL_INTERVAL}.
        </caption>
        <thead>
          <tr className="text-text-muted">
            <th scope="col" className="py-2 pr-3 text-left font-normal">
              Level
            </th>
            <th scope="col" className="num py-2 px-3 font-normal">
              Lines
            </th>
            <th scope="col" className="num py-2 px-3 font-normal">
              Seconds
            </th>
            <th scope="col" className="w-1/3 py-2 pl-3 text-left font-normal">
              <span className="sr-only">Speed against level 1</span>
            </th>
          </tr>
        </thead>
        <tbody className="divide-y divide-line border-y border-line">
          {levels.map((level) => {
            const seconds = fallInterval(level);
            return (
              <tr key={level}>
                <th scope="row" className="py-2 pr-3 text-left font-display font-normal">
                  {level === lastLevel ? `${level}+` : level}
                </th>
                <td className="num px-3 py-2">{linesToReach(level)}</td>
                <td className="num px-3 py-2">{seconds.toFixed(3)}</td>
                <td className="py-2 pl-3" aria-hidden>
                  <span
                    className="bar"
                    style={{ width: `${(seconds / BASE_FALL_INTERVAL) * 100}%` }}
                  />
                </td>
              </tr>
            );
          })}
        </tbody>
      </table>
    </div>
  );
}
