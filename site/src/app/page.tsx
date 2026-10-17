import { Wordmark } from "@/components/wordmark";
import { apiBase, downloadUrl, grounds, pieceColors, repo } from "@/lib/site";

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

        {/* Two grounds, one system */}
        <section className="flex flex-col gap-4">
          <h2 className="text-sm font-semibold tracking-wide text-text-muted">TWO GROUNDS</h2>
          <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
            {Object.entries(grounds).map(([key, g]) => (
              <div
                key={key}
                className="flex flex-col gap-3 rounded-cell border border-line p-4"
                style={{ background: g.background, color: g.ink }}
              >
                <span className="font-display tracking-[0.14em]">{g.label.toUpperCase()}</span>
                <div className="flex gap-1.5">
                  {pieceColors.map((c) => (
                    <span
                      key={c}
                      className="h-5 w-5 rounded-cell"
                      style={{ background: c }}
                      aria-hidden
                    />
                  ))}
                </div>
                <span className="text-xs opacity-70">
                  Seven piece colors, readable in grayscale.
                </span>
              </div>
            ))}
          </div>
        </section>

        {/* Facts — plain rows, no icon cards */}
        <section className="flex flex-col">
          <h2 className="mb-4 text-sm font-semibold tracking-wide text-text-muted">
            THE SHORT LIST
          </h2>
          <ul className="flex flex-col divide-y divide-line">
            {[
              [
                "Offline first",
                "The whole game runs without a network. Sync is optional and silent.",
              ],
              [
                "No ads, no purchases",
                "Nothing is for sale and nothing nags. The game is the product.",
              ],
              [
                "Global leaderboard",
                "Sign in only if you want to. Best score, top 50, one small API.",
              ],
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
        <a className="hover:text-text" href={`${apiBase}/privacy`}>
          Privacy
        </a>
        <a className="hover:text-text" href={`${apiBase}/account/delete`}>
          Delete account
        </a>
        <a className="hover:text-text" href="mailto:shahadathhossensajib732@gmail.com">
          Contact
        </a>
        <a className="hover:text-text" href={`${repo}/blob/main/LICENSE`}>
          MIT
        </a>
        <span className="ml-auto">DropGrid</span>
      </footer>
    </div>
  );
}
