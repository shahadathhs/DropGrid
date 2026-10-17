import Link from "next/link";

export default function NotFound() {
  return (
    <div className="flex min-h-screen flex-col items-center justify-center gap-4 px-5 text-center">
      <p className="font-display text-6xl tracking-widest">404</p>
      <p className="text-text-muted">That page dropped out.</p>
      <Link href="/" className="text-sm underline underline-offset-4">
        Back to the game
      </Link>
    </div>
  );
}
