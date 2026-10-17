import { PhoneFrame } from "@/components/phone-frame";
import { GameScreen } from "@/components/screens/game-screen";
import { LeaderboardScreen } from "@/components/screens/leaderboard-screen";
import { MenuScreen } from "@/components/screens/menu-screen";
import { ModePickerScreen } from "@/components/screens/mode-picker-screen";
import { SettingsScreen } from "@/components/screens/settings-screen";
import { StatsScreen } from "@/components/screens/stats-screen";

const steps = [
  {
    title: "Menu",
    body: "Your best score, Play, and a row of links: Stats, Levels, Leaderboard, Sign in, Settings.",
    screen: <MenuScreen />,
  },
  {
    title: "Choose mode",
    body: "Marathon, Sprint, Ultra, Daily and Zen. Marathon asks for a start level next.",
    screen: <ModePickerScreen />,
  },
  {
    title: "Play",
    body: "Hold, the next three pieces, a ghost, and one row of touch controls.",
    screen: <GameScreen />,
  },
  {
    title: "Stats",
    body: "Best score, total lines, games played, and a best for each mode you have played.",
    screen: <StatsScreen />,
  },
  {
    title: "Leaderboard",
    body: "Rank, name, best. Guests can read it. Sign in to appear on it.",
    screen: <LeaderboardScreen />,
  },
  {
    title: "Settings",
    body: "Sound, music, ground, ghost piece, left-handed, large buttons, haptics.",
    screen: <SettingsScreen />,
  },
];

/**
 * Each screen of the app, with one true sentence. On wide screens that scroll
 * with timelines, one phone stays pinned and its screen changes with the step in
 * view (opacity only) and the step's text is
 * full ink while it is the one in view, quieter otherwise. Everywhere else each step shows its own phone inline.
 * Both variants are in the markup; the pinned one is aria-hidden.
 */
export function ScreenTour() {
  return (
    <section className="tour wrap py-12 lg:py-24" aria-labelledby="tour-title">
      <h2 id="tour-title" className="reveal font-display text-2xl lg:text-4xl">
        The screens
      </h2>

      <div className="tour-grid mt-8 lg:mt-12">
        <ol className="flex flex-col">
          {steps.map((s, i) => (
            <li
              key={s.title}
              id={`step-${i + 1}`}
              data-step={i + 1}
              className="tour-step flex flex-col gap-5 border-t border-line py-8 sm:flex-row sm:items-center sm:gap-10"
            >
              <div className="tour-text flex flex-col gap-3 sm:flex-1" data-step={i + 1}>
                <div className="flex items-baseline gap-4">
                  <span aria-hidden className="tour-index font-display text-2xl text-text-faint">
                    {String(i + 1).padStart(2, "0")}
                  </span>
                  <h3 className="font-display text-2xl lg:text-5xl">{s.title}</h3>
                </div>
                <p className="measure text-sm text-text-muted lg:text-lg">{s.body}</p>
              </div>
              <div className="tour-inline flex justify-center sm:flex-1 sm:justify-end">
                <PhoneFrame size="md" className="max-w-[15rem]">
                  {s.screen}
                </PhoneFrame>
              </div>
            </li>
          ))}
        </ol>

        <div className="tour-pinned" aria-hidden>
          <div
            className="sticky"
            style={{
              ["--w" as string]: "min(22rem, calc((100svh - 5rem) / 2.25))",
              width: "var(--w)",
              top: "calc((100svh - var(--w) * 2.25) / 2)",
            }}
          >
            <PhoneFrame className="lg:max-w-none">
              <div className="relative">
                {steps.map((s, i) => (
                  <div
                    key={s.title}
                    data-step={i + 1}
                    className={i === 0 ? "tour-screen" : "tour-screen absolute inset-0"}
                  >
                    {s.screen}
                  </div>
                ))}
              </div>
            </PhoneFrame>
          </div>
        </div>
      </div>
    </section>
  );
}
