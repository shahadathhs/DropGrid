import { LINE_POINTS, MAX_START_LEVEL, pointsForLines } from "@/lib/game-rules";

const counts = [1, 2, 3, 4];
const levels = Array.from({ length: MAX_START_LEVEL }, (_, i) => i + 1);

/** Points per lines cleared at once, per level: LINE_POINTS × level. */
export function ScoreTable() {
  return (
    <div className="max-w-xl overflow-x-auto">
      <table className="w-full text-xs sm:text-sm">
        <caption className="pb-3 text-left text-text-muted">
          Points for one clear, by level. Base values: {LINE_POINTS.slice(1).join(", ")}.
        </caption>
        <thead>
          <tr className="text-text-muted">
            <th scope="col" className="py-2 pr-3 text-left font-normal">
              Level
            </th>
            {counts.map((c) => (
              <th key={c} scope="col" className="num py-2 pl-3 font-normal">
                {c} {c === 1 ? "line" : "lines"}
              </th>
            ))}
          </tr>
        </thead>
        <tbody className="divide-y divide-line border-y border-line">
          {levels.map((level) => (
            <tr key={level}>
              <th scope="row" className="py-2 pr-3 text-left font-display font-normal">
                {level}
              </th>
              {counts.map((c) => (
                <td key={c} className="num py-2 pl-3">
                  {pointsForLines(c, level).toLocaleString("en-US")}
                </td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
