import Link from "next/link";
import { PageShell } from "@/components/page-shell";

export default function NotFound() {
  return (
    <PageShell>
      <div className="wrap flex flex-1 flex-col items-center justify-center gap-4 py-24 text-center">
        <p className="font-display text-6xl tracking-widest">404</p>
        <p className="text-text-muted">That page dropped out.</p>
        <Link href="/" className="link-quiet py-1 text-sm">
          Back to the game
        </Link>
      </div>
    </PageShell>
  );
}
