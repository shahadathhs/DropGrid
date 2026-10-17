import { cn } from "@/lib/cn";

/** A phone-sized chrome around a screen. Flat: one border, no shadows. */
export function PhoneFrame({
  children,
  className,
}: {
  children: React.ReactNode;
  className?: string;
}) {
  return (
    <div
      className={cn(
        "rounded-[2.25rem] border border-line-strong bg-background-deep p-2",
        className,
      )}
    >
      <div className="overflow-hidden rounded-[1.75rem] border border-line bg-background">
        <div className="flex h-7 items-center justify-center" aria-hidden>
          <span className="h-1.5 w-16 rounded-cell bg-line-strong" />
        </div>
        {children}
      </div>
    </div>
  );
}
