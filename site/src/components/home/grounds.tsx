import { PhoneFrame } from "@/components/phone-frame";
import { GameScreen } from "@/components/screens/game-screen";

/** Graphite and paper side by side: the same game, the Ground setting. */
export function Grounds() {
  return (
    <section className="wrap py-12 lg:py-24" aria-labelledby="grounds-title">
      <div className="grid gap-8 lg:grid-cols-[1fr_auto] lg:items-center lg:gap-24">
        <div className="reveal flex flex-col gap-3">
          <h2 id="grounds-title" className="font-display text-2xl lg:text-4xl">
            Two grounds
          </h2>
          <p className="measure text-sm text-text-muted lg:text-base">
            Graphite or paper, set in Settings. The same board, the same seven piece colors, and
            each stays distinct in grayscale.
          </p>
        </div>
        <div className="reveal-stagger grid grid-cols-2 gap-4 sm:gap-8 lg:w-[34rem]">
          <figure className="flex flex-col items-center gap-3">
            <PhoneFrame size="md" className="max-w-[16rem]">
              <GameScreen />
            </PhoneFrame>
            <figcaption className="text-xs text-text-muted">Graphite</figcaption>
          </figure>
          <figure className="flex flex-col items-center gap-3">
            <PhoneFrame size="md" className="max-w-[16rem]">
              <GameScreen light />
            </PhoneFrame>
            <figcaption className="text-xs text-text-muted">Paper</figcaption>
          </figure>
        </div>
      </div>
    </section>
  );
}
