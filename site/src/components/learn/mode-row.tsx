import { cn } from "@/lib/cn";
import { PhoneFrame } from "@/components/phone-frame";
import { GameScreen } from "@/components/screens/game-screen";
import { modeFacts } from "@/lib/mode-rules";
import type { Mode } from "@/lib/modes";
import type { ModeId } from "@/lib/mode-rules";

const labels: [keyof (typeof modeFacts)["marathon"], string][] = [
  ["goal", "Goal"],
  ["ends", "Ends"],
  ["clock", "Clock"],
  ["start", "Starts at"],
];

/**
 * One mode: name, the picker's line, the real rules, what it ranks, and a phone
 * showing that mode's HUD. Rows alternate sides on wide screens; on a phone the
 * screen sits under its text.
 */
export function ModeRow({ mode, index }: { mode: Mode; index: number }) {
  const id = mode.id as ModeId;
  const facts = modeFacts[id];
  return (
    <section
      id={id}
      aria-labelledby={`${id}-title`}
      className="mode-row reveal grid scroll-mt-4 gap-8 py-10 lg:grid-cols-2 lg:items-center lg:gap-24 lg:py-20"
    >
      <div className={cn("flex flex-col gap-5", index % 2 === 1 && "lg:order-2")}>
        <div className="flex flex-col gap-2">
          <h2 id={`${id}-title`} className="mode-name font-display text-3xl lg:text-5xl">
            <a href={`#${id}`}>{mode.name}</a>
          </h2>
          <p className="measure text-sm text-text-muted lg:text-base">{mode.tagline}</p>
        </div>
        <dl className="flex flex-col gap-4 text-sm">
          {labels.map(([key, label]) => (
            <div key={key} className="grid gap-1 sm:grid-cols-[6.5rem_1fr] sm:gap-4">
              <dt className="text-xs uppercase tracking-widest">{label}</dt>
              <dd className="measure">{facts[key]}</dd>
            </div>
          ))}
          <div className="grid gap-1 sm:grid-cols-[6.5rem_1fr] sm:gap-4">
            <dt className="text-xs uppercase tracking-widest">Ranks</dt>
            <dd className="mode-rank measure">{mode.board}</dd>
          </div>
        </dl>
      </div>
      <div className={cn("flex justify-center", index % 2 === 1 ? "lg:order-1" : "lg:justify-end")}>
        <PhoneFrame className="mode-phone">
          <GameScreen mode={id} />
        </PhoneFrame>
      </div>
    </section>
  );
}
