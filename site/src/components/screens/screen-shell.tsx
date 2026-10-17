import { cn } from "@/lib/cn";

/**
 * The inside of a phone: a 720-unit-wide size container with the ground applied.
 * `light` switches to the paper ground. Children use var(--u), one design unit.
 */
export function ScreenShell({
  light = false,
  children,
}: {
  light?: boolean;
  children: React.ReactNode;
}) {
  return (
    <div className={cn("scr", light && "light")}>
      <div className="scr-in">{children}</div>
    </div>
  );
}
