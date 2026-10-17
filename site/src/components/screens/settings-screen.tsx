import { ScreenShell } from "@/components/screens/screen-shell";
import { ScreenTop } from "@/components/screens/screen-top";

const APPLIES = "Applies next launch.";

/** The seven settings with the game's labels and hints at their default states. */
export function SettingsScreen({ light = false }: { light?: boolean }) {
  const rows: { label: string; hint: string; on: boolean }[] = [
    { label: "Sound", hint: "Effects and stings", on: true },
    { label: "Music", hint: "The background loops", on: false },
    { label: "Ground", hint: `Graphite or paper. ${APPLIES}`, on: light },
    { label: "Ghost piece", hint: "Show where the piece will land", on: true },
    { label: "Left-handed", hint: `Mirror the touch controls. ${APPLIES}`, on: false },
    { label: "Large buttons", hint: `Bigger touch controls. ${APPLIES}`, on: false },
    { label: "Haptics", hint: "Vibrate on line clears", on: true },
  ];
  return (
    <ScreenShell light={light}>
      <ScreenTop title="Settings" />
      <div style={{ display: "flex", flexDirection: "column", gap: "calc(var(--u) * 12)" }}>
        {rows.map((r) => (
          <div key={r.label} className="scr-card" style={{ minHeight: "calc(var(--u) * 132)" }}>
            <div className="scr-card-text">
              <span className="scr-card-name">{r.label}</span>
              <span className="scr-card-hint">{r.hint}</span>
            </div>
            <span className="scr-switch" data-on={r.on ? "" : undefined} />
          </div>
        ))}
      </div>
    </ScreenShell>
  );
}
