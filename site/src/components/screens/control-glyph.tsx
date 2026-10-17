import type { Control } from "@/lib/controls";

/** One touch button, drawn as the game draws it: its icon, or the word HOLD. */
export function ControlGlyph({ control }: { control: Control }) {
  return (
    <span className={"ctl" + (control.drop ? " ctl--drop" : "")}>
      {control.d ? (
        <svg
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          strokeWidth="2"
          strokeLinecap="round"
          strokeLinejoin="round"
        >
          <path d={control.d} />
        </svg>
      ) : (
        <span className="ctl-text">HOLD</span>
      )}
    </span>
  );
}
