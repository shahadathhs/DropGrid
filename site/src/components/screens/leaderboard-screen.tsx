import { ScreenShell } from "@/components/screens/screen-shell";
import { ScreenTop } from "@/components/screens/screen-top";

/**
 * The leaderboard as a guest meets it with nothing to show yet: the title, the
 * empty state, and the sign-in note. Rows are rank, name, best score (not shown
 * here: no invented players).
 */
export function LeaderboardScreen({ light = false }: { light?: boolean }) {
  return (
    <ScreenShell light={light}>
      <ScreenTop title="LEADERBOARD" />
      <div className="scr-muted">No scores yet</div>
      <div style={{ flex: 1 }} />
      <div
        className="scr-muted"
        style={{ textAlign: "center", marginBottom: "calc(var(--u) * 24)" }}
      >
        Sign in to appear here
      </div>
      <div className="scr-primary">Sign in</div>
    </ScreenShell>
  );
}
