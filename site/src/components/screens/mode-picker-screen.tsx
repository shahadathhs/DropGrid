import { ScreenShell } from "@/components/screens/screen-shell";
import { ScreenTop } from "@/components/screens/screen-top";
import { modes } from "@/lib/modes";

/** The mode picker: one card per mode, with the game's names and taglines. */
export function ModePickerScreen({ light = false }: { light?: boolean }) {
  return (
    <ScreenShell light={light}>
      <ScreenTop title="Choose mode" />
      <div style={{ display: "flex", flexDirection: "column", gap: "calc(var(--u) * 12)" }}>
        {modes.map((m) => (
          <div key={m.id} className="scr-card">
            <div className="scr-card-text">
              <span className="scr-card-name">{m.name}</span>
              <span className="scr-card-hint">{m.tagline}</span>
            </div>
          </div>
        ))}
      </div>
    </ScreenShell>
  );
}
