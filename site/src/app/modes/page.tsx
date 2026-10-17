import type { Metadata } from "next";
import Link from "next/link";
import "../learn.css";
import { ModeRow } from "@/components/learn/mode-row";
import { PageShell } from "@/components/page-shell";
import { downloadUrl } from "@/lib/links";
import { modes } from "@/lib/modes";

export const metadata: Metadata = {
  title: "Modes",
  description:
    "Marathon, Sprint, Ultra, Daily and Zen. The falling rules are the same in each; how a run ends and what it ranks differ.",
  alternates: { canonical: "/modes" },
};

export default function Modes() {
  return (
    <PageShell current="/modes">
      <header className="wrap flex flex-col gap-4 pt-2 pb-8 lg:pt-8 lg:pb-12">
        <h1 className="font-display text-[1.7rem] leading-[1.15] sm:text-4xl lg:text-6xl">Modes</h1>
        <p className="measure text-sm text-text-muted lg:text-lg">
          Five modes. The falling rules are the same in each. The end of a run and the ranking
          differ.
        </p>
        <nav aria-label="Modes" className="flex flex-wrap gap-x-5 gap-y-1 text-sm">
          {modes.map((m) => (
            <a key={m.id} href={`#${m.id}`} className="link-quiet py-1">
              {m.name}
            </a>
          ))}
        </nav>
      </header>

      <div className="wrap">
        {modes.map((m, i) => (
          <ModeRow key={m.id} mode={m} index={i} />
        ))}
      </div>

      <section className="wrap flex flex-wrap items-center gap-x-6 gap-y-3 border-t border-line pt-10 pb-20 lg:pt-16 lg:pb-28">
        <a
          href={downloadUrl}
          className="btn-primary px-5 py-3 text-sm font-semibold lg:px-6 lg:py-4 lg:text-base"
        >
          Get the latest build
        </a>
        <Link href="/how-to-play" className="link-quiet py-2 text-sm">
          How to play
        </Link>
      </section>
    </PageShell>
  );
}
