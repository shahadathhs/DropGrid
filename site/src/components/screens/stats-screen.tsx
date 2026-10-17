import { ScreenShell } from "@/components/screens/screen-shell";
import { ScreenTop } from "@/components/screens/screen-top";
import { LINES, SCORE } from "@/lib/board-data";
import { thousands } from "@/lib/format";

/**
 * The stats screen after one finished game (the board state on the game screen):
 * lifetime totals, then a best for each mode played (only modes with a result
 * get a row, as stats_screen.gd does).
 */
const ROWS = [
  ["BEST SCORE", thousands(SCORE)],
  ["TOTAL LINES", thousands(LINES)],
  ["GAMES PLAYED", "1"],
  ["MARATHON BEST", thousands(SCORE)],
];

export function StatsScreen({ light = false }: { light?: boolean }) {
  return (
    <ScreenShell light={light}>
      <ScreenTop title="Stats" />
      <div>
        {ROWS.map(([label, value]) => (
          <div key={label} className="scr-stat">
            <span className="scr-muted">{label}</span>
            <span className="scr-stat-value">{value}</span>
          </div>
        ))}
      </div>
    </ScreenShell>
  );
}
