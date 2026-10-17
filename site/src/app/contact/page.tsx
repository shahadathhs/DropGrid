import type { Metadata } from "next";
import { Wordmark } from "@/components/wordmark";
import { repo } from "@/lib/links";

export const metadata: Metadata = {
  title: "Contact · DropGrid",
};

export default function Contact() {
  return (
    <div className="mx-auto flex min-h-screen max-w-3xl flex-col px-5">
      <header className="py-6">
        <Wordmark />
      </header>

      <main className="flex flex-1 flex-col gap-8 pt-6 pb-20">
        <h1 className="text-2xl font-semibold">Contact</h1>
        <ul className="flex flex-col divide-y divide-line">
          <li className="flex flex-col gap-1 py-4 sm:flex-row sm:gap-6">
            <span className="w-48 shrink-0 text-sm font-semibold">Bugs and crashes</span>
            <span className="text-text-muted">
              Open an issue on{" "}
              <a
                className="underline underline-offset-4 hover:text-text"
                href={`${repo}/issues/new`}
              >
                GitHub
              </a>
              . A screenshot and the steps help.
            </span>
          </li>
          <li className="flex flex-col gap-1 py-4 sm:flex-row sm:gap-6">
            <span className="w-48 shrink-0 text-sm font-semibold">Everything else</span>
            <span className="text-text-muted">
              <a
                className="underline underline-offset-4 hover:text-text"
                href="mailto:shahadathhossensajib732@gmail.com"
              >
                shahadathhossensajib732@gmail.com
              </a>
            </span>
          </li>
        </ul>
      </main>

      <footer className="border-t border-line py-6 text-sm text-text-faint">
        <a className="hover:text-text" href="/">
          Back to the game
        </a>
      </footer>
    </div>
  );
}
