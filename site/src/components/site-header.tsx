import Link from "next/link";
import { Wordmark } from "@/components/wordmark";
import { navLinks } from "@/lib/nav";
import { repo } from "@/lib/links";

/**
 * Wordmark left, four page links, a quiet Source link. A plain link row that
 * wraps on a 390px phone: no menu, no JavaScript. `current` marks the page.
 */
export function SiteHeader({ current }: { current?: string }) {
  return (
    <header className="wrap flex flex-wrap items-center justify-between gap-x-6 gap-y-3 py-4 md:py-6">
      <Link href="/" aria-label="DropGrid, home">
        <Wordmark />
      </Link>
      <nav
        aria-label="Primary"
        className="order-3 flex w-full flex-wrap gap-x-3 gap-y-1 text-[0.6875rem] sm:gap-x-4 sm:text-xs md:order-none md:w-auto md:gap-x-8 md:text-sm"
      >
        {navLinks.map((l) => (
          <Link
            key={l.href}
            href={l.href}
            className="link-quiet py-1"
            aria-current={current === l.href ? "page" : undefined}
          >
            {l.label}
          </Link>
        ))}
      </nav>
      <a href={repo} className="link-quiet py-1 text-xs md:text-sm">
        Source
      </a>
    </header>
  );
}
