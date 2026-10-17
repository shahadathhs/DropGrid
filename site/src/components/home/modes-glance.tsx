import Link from "next/link";
import { modes } from "@/lib/modes";

/** Five plain rows. Hover or keyboard focus lights a row and shows what it ranks. */
export function ModesGlance() {
  return (
    <section className="wrap py-12 lg:py-24" aria-labelledby="modes-title">
      <div className="flex flex-wrap items-baseline justify-between gap-4">
        <h2 id="modes-title" className="reveal font-display text-2xl lg:text-4xl">
          Five modes
        </h2>
        <Link href="/modes" className="link-quiet py-1 text-sm">
          All modes
        </Link>
      </div>
      <ul className="reveal-stagger mt-6 flex flex-col divide-y divide-line border-y border-line lg:mt-10">
        {modes.map((m) => (
          <li key={m.id}>
            <Link
              href="/modes"
              className="row-hover grid gap-1 px-2 py-4 sm:grid-cols-[9rem_1fr_20rem] sm:items-baseline sm:gap-6 lg:py-5"
            >
              <span className="row-name font-display text-lg">{m.name}</span>
              <span className="text-sm text-text-muted">{m.rule}</span>
              <span className="row-detail text-xs text-text-faint sm:text-right">{m.board}</span>
            </Link>
          </li>
        ))}
      </ul>
    </section>
  );
}
