import { cn } from "@/lib/site";

/** The game's wordmark, set in Departure Mono with the same wide tracking. */
export function Wordmark({ className }: { className?: string }) {
  return (
    <span className={cn("font-display text-2xl leading-none tracking-[0.18em]", className)}>
      DROPGRID
    </span>
  );
}
