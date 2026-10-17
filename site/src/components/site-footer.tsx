import Link from "next/link";

export function SiteFooter() {
  return (
    <footer className="mt-auto border-t border-line">
      <div className="wrap flex flex-wrap items-center gap-x-6 gap-y-2 py-6 text-xs md:text-sm">
        <Link className="link-quiet py-1" href="/privacy">
          Privacy
        </Link>
        <Link className="link-quiet py-1" href="/contact">
          Contact
        </Link>
        <span className="text-text-faint sm:ml-auto">© 2026 DropGrid</span>
      </div>
    </footer>
  );
}
