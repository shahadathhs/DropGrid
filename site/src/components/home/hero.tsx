import Link from "next/link";
import { GameScreen } from "@/components/screens/game-screen";
import { PhoneFrame } from "@/components/phone-frame";
import { downloadUrl } from "@/lib/links";

/**
 * Headline, the one primary button, and the real game screen. Scrolling plays
 * it: the active piece falls cell by cell to its ghost, completes two rows, and
 * the cells above drop (motion.css).
 */
export function Hero() {
  return (
    <section className="wrap grid items-center gap-5 pt-2 pb-12 lg:grid-cols-[1fr_auto] lg:gap-20 lg:pt-8 lg:pb-24">
      <div className="flex flex-col gap-4 lg:gap-7">
        <h1 className="font-display text-[1.7rem] leading-[1.15] text-balance sm:text-4xl lg:text-6xl">
          A falling-block puzzle for Android.
        </h1>
        <p className="measure text-sm text-text-muted lg:text-lg">
          Offline first. No ads, no purchases. Five modes, one global leaderboard.
        </p>
        <div className="flex flex-wrap items-center gap-x-6 gap-y-3">
          <a
            href={downloadUrl}
            className="btn-primary px-5 py-3 text-sm font-semibold lg:px-6 lg:py-4 lg:text-base"
          >
            Get the latest build
          </a>
          <Link href="/how-to-play" className="link-quiet py-2 text-sm">
            How to play
          </Link>
        </div>
      </div>
      <div className="flex justify-center lg:w-[22rem] lg:justify-end">
        <PhoneFrame className="lg:max-w-none">
          <GameScreen animated />
        </PhoneFrame>
      </div>
    </section>
  );
}
