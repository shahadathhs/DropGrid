import Link from "next/link";
import { GameScreen } from "@/components/game-screen";
import { PhoneFrame } from "@/components/phone-frame";
import { Wordmark } from "@/components/wordmark";
import { downloadUrl, repo } from "@/lib/links";

export default function Home() {
  return (
    <div className="mx-auto flex min-h-screen max-w-3xl flex-col px-5">
      <header className="flex items-center justify-between py-6">
        <Wordmark />
        <a
          href={repo}
          className="text-sm text-text-muted underline-offset-4 transition-colors hover:text-text hover:underline"
        >
          Source
        </a>
      </header>

      <main className="flex flex-1 flex-col gap-16 pb-20">
        {/* Hero */}
        <section className="flex flex-col gap-6 pt-10">
          <h1 className="text-3xl leading-snug font-semibold text-balance">
            A falling-block puzzle for Android.
          </h1>
          <p className="max-w-prose text-lg text-text-muted">
            Offline first. No ads, no purchases. Clear lines, chase your best, and start at any
            level you have unlocked. An optional account puts your best score on a global
            leaderboard.
          </p>
          <div className="flex items-center gap-4 pt-2">
            <a
              href={downloadUrl}
              className="rounded-cell bg-accent px-5 py-3 text-sm font-semibold text-accent-ink transition-opacity hover:opacity-90"
            >
              Get the latest build
            </a>
            <span className="text-sm text-text-faint">free · Android 8+</span>
          </div>
        </section>

        {/* The game itself: two grounds of one real board state */}
        <section className="flex flex-col gap-4">
          <h2 className="text-sm font-semibold tracking-wide text-text-muted">
            TWO GROUNDS, ONE GAME
          </h2>
          <div className="grid grid-cols-1 justify-items-center gap-6 sm:grid-cols-2">
            <figure className="flex flex-col items-center gap-3">
              <PhoneFrame>
                <GameScreen />
              </PhoneFrame>
              <figcaption className="text-xs tracking-[0.18em] text-text-faint">
                GRAPHITE
              </figcaption>
            </figure>
            <figure className="flex flex-col items-center gap-3">
              <PhoneFrame>
                <GameScreen light />
              </PhoneFrame>
              <figcaption className="text-xs tracking-[0.18em] text-text-faint">PAPER</figcaption>
            </figure>
          </div>
          <p className="text-sm text-text-muted">
            A real mid-game state rendered by the same rules the app plays. Graphite for the desk,
            paper for the sun — one cell, seven piece colors that stay readable in grayscale.
          </p>
        </section>

        {/* Facts — plain rows, no icon cards */}
        <section className="flex flex-col">
          <h2 className="mb-4 text-sm font-semibold tracking-wide text-text-muted">
            THE SHORT LIST
          </h2>
          <ul className="flex flex-col divide-y divide-line">
            {[
              ["Offline first", "The whole game runs without a network."],
              ["No ads, no purchases", "Nothing is for sale. Nothing nags."],
              ["Global leaderboard", "Sign in only if you want to. Your best score, top 50."],
              [
                "Start at your level",
                "Ten start levels. Unlock the next by clearing lines, not by paying.",
              ],
            ].map(([title, body]) => (
              <li key={title} className="flex flex-col gap-1 py-4 sm:flex-row sm:gap-6">
                <span className="w-48 shrink-0 text-sm font-semibold">{title}</span>
                <span className="text-text-muted">{body}</span>
              </li>
            ))}
          </ul>
        </section>
      </main>

      <footer className="flex flex-wrap items-center gap-x-6 gap-y-2 border-t border-line py-6 text-sm text-text-faint">
        <Link className="hover:text-text" href="/privacy">
          Privacy
        </Link>
        <Link className="hover:text-text" href="/contact">
          Contact
        </Link>
        <span className="ml-auto">© 2026 DropGrid</span>
      </footer>
    </div>
  );
}
