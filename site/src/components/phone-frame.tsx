import { cn } from "@/lib/cn";

/**
 * A device around a screen. The bezel is hardware, not UI, so its corners are
 * exempt from the 4px rule; everything drawn inside the screen uses the cell
 * radius. Flat: one border, no shadow. `size="sm"` is the small-screen variant.
 * The picture is decorative: put the real text in the copy beside it.
 */
export function PhoneFrame({
  children,
  size = "md",
  className,
}: {
  children: React.ReactNode;
  size?: "md" | "sm";
  className?: string;
}) {
  const small = size === "sm";
  return (
    <div
      aria-hidden
      className={cn(
        "relative w-full border border-line-strong bg-surface-3",
        small
          ? "max-w-[10.5rem] rounded-[1.5rem] p-[0.3rem]"
          : "max-w-[19rem] rounded-[2.5rem] p-2",
        className,
      )}
    >
      <div
        className={cn(
          "relative overflow-hidden bg-background",
          small ? "rounded-[1.25rem]" : "rounded-[2rem]",
        )}
      >
        {children}
        <span
          className={cn(
            "absolute left-1/2 -translate-x-1/2 rounded-full bg-surface-3",
            small ? "top-[0.45rem] size-[0.4rem]" : "top-[0.7rem] size-[0.65rem]",
          )}
        />
      </div>
    </div>
  );
}
