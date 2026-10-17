import type { Metadata } from "next";
import Link from "next/link";
import { BoardTable } from "@/components/leaderboard/board-table";
import { LeaderboardScreen } from "@/components/screens/leaderboard-screen";
import { PageShell } from "@/components/page-shell";
import { PhoneFrame } from "@/components/phone-frame";
import { boards, fetchBoard } from "@/lib/leaderboard";
import "./leaderboard.css";

export const revalidate = 3600;

export const metadata: Metadata = {
  title: "Leaderboard",
  description: "The top 50 on each DropGrid board: Marathon, Sprint, Ultra and Daily.",
  alternates: { canonical: "/leaderboard" },
};

export default async function Leaderboard() {
  const results = await Promise.all(boards.map((b) => fetchBoard(b.id)));
  return (
    <PageShell current="/leaderboard">
      <div className="wrap grid gap-10 pt-6 pb-20 lg:grid-cols-[22rem_1fr] lg:gap-20">
        <div className="flex flex-col gap-6 lg:sticky lg:top-6 lg:self-start">
          <h1 className="font-display text-3xl lg:text-5xl">Leaderboard</h1>
          <p className="text-sm text-text-muted">The top 50 on each board. Refreshed every hour.</p>
          <nav aria-label="Boards" className="flex flex-wrap gap-x-5 gap-y-1 text-sm">
            {boards.map((b) => (
              <a key={b.id} href={`#${b.id}`} className="link-quiet py-1">
                {b.name}
              </a>
            ))}
          </nav>
          <p className="text-sm text-text-muted">
            Play signed in to appear on a board. Zen earns nothing.
          </p>
          <div>
            <Link
              href="/download"
              className="btn-primary inline-block px-5 py-3 text-sm font-semibold"
            >
              Download
            </Link>
          </div>
          <div className="hidden lg:flex lg:flex-col lg:gap-3">
            <PhoneFrame className="phone-hover max-w-[16rem]">
              <LeaderboardScreen />
            </PhoneFrame>
            <p className="text-xs text-text-faint">The leaderboard screen in the app.</p>
          </div>
        </div>
        <div className="flex min-w-0 flex-col gap-14">
          {boards.map((b, i) => (
            <BoardTable
              key={b.id}
              id={b.id}
              name={b.name}
              note={b.note}
              unit={b.id === "sprint" ? "Time" : "Score"}
              rows={results[i] ?? null}
            />
          ))}
        </div>
      </div>
    </PageShell>
  );
}
