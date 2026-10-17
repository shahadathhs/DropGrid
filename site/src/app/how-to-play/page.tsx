import type { Metadata } from "next";
import Link from "next/link";
import "../learn.css";
import { ControlPad } from "@/components/learn/control-pad";
import { GhostDiagram } from "@/components/learn/ghost-diagram";
import { LockTimeline } from "@/components/learn/lock-timeline";
import { PieceSpecimen } from "@/components/learn/piece-specimen";
import { ScoreTable } from "@/components/learn/score-table";
import { SectionList } from "@/components/learn/section-list";
import { SpeedTable } from "@/components/learn/speed-table";
import { PageShell } from "@/components/page-shell";
import { ControlGlyph } from "@/components/screens/control-glyph";
import { type Control, HARD, HOLD, LEFT, RIGHT, ROTATE, SOFT } from "@/lib/controls";
import {
  BACK_TO_BACK_MULTIPLIER,
  COMBO_BONUS,
  LINES_PER_LEVEL,
  LOCK_DELAY,
  MAX_LOCK_RESETS,
  MAX_START_LEVEL,
  MOVE_REPEAT_DELAY,
  MOVE_REPEAT_INTERVAL,
  NEXT_QUEUE_SIZE,
  SOFT_DROP_INTERVAL,
  pointsForLines,
} from "@/lib/game-rules";
import { downloadUrl } from "@/lib/links";
import { PIECE_LETTERS } from "@/lib/pieces";

export const metadata: Metadata = {
  title: "How to play",
  description:
    "The controls, the seven pieces, the scoring table, how fast each level falls, and the hold, next queue and lock delay rules.",
  alternates: { canonical: "/how-to-play" },
};

const sections = [
  { id: "controls", label: "Controls" },
  { id: "pieces", label: "Pieces" },
  { id: "scoring", label: "Scoring" },
  { id: "levels", label: "Levels and speed" },
  { id: "hold", label: "Hold, next, lock delay" },
];

const buttons: { controls: Control[]; name: string; text: string }[] = [
  {
    controls: [LEFT, RIGHT],
    name: "Left, Right",
    text: `Move the piece one cell. Hold a button to repeat: first after ${MOVE_REPEAT_DELAY} s, then every ${MOVE_REPEAT_INTERVAL} s.`,
  },
  {
    controls: [ROTATE],
    name: "Rotate",
    text: "Turns the piece a quarter turn clockwise. If something is in the way, the game tries the turn shifted one cell left, one right, two left, then two right. The O piece does not turn.",
  },
  {
    controls: [HOLD],
    name: "Hold",
    text: "Swaps the falling piece with the held one. One swap per piece.",
  },
  {
    controls: [SOFT],
    name: "Soft drop",
    text: `Hold to fall fast: one step every ${SOFT_DROP_INTERVAL} s, the first one at once. Let go and the level's pace returns.`,
  },
  {
    controls: [HARD],
    name: "Hard drop",
    text: "Drops the piece straight to its ghost and locks it at once. It sits apart from the others, in the signal color.",
  },
];

const pieceRows = PIECE_LETTERS.map((letter, piece) => ({ letter, piece }));
/** Brightest last, on the dark ground (docs/README_VISUAL_DESIGN.md). */
const grayOrder = [5, 2, 4, 3, 6, 0, 1];

const base4 = pointsForLines(4, 1);
const example = {
  level: 2,
  plain: base4 * 2,
  b2b: base4 * 2 * BACK_TO_BACK_MULTIPLIER,
  combo: COMBO_BONUS * 2 * 2,
};

function Heading({ id, children }: { id: string; children: React.ReactNode }) {
  return (
    <h2 id={id} className="reveal font-display text-2xl lg:text-4xl">
      {children}
    </h2>
  );
}

export default function HowToPlay() {
  return (
    <PageShell current="/how-to-play">
      <header className="wrap flex flex-col gap-4 pt-2 pb-8 lg:pt-8 lg:pb-12">
        <h1 className="font-display text-[1.7rem] leading-[1.15] sm:text-4xl lg:text-6xl">
          How to play
        </h1>
        <p className="measure text-sm text-text-muted lg:text-lg">
          Pieces fall. Fill a row on the 10 by 20 board and it clears.
        </p>
      </header>

      <div className="wrap htp grid gap-8 pb-20 lg:grid-cols-[13rem_1fr] lg:gap-16 lg:pb-28">
        <aside className="lg:sticky lg:top-6 lg:self-start">
          <SectionList items={sections} />
        </aside>

        <div className="flex min-w-0 flex-col">
          <section
            id="controls"
            data-s="1"
            aria-labelledby="controls-h"
            className="htp-section flex scroll-mt-4 flex-col gap-6 pb-14 lg:pb-24"
          >
            <Heading id="controls-h">Controls</Heading>
            <p className="measure text-sm text-text-muted">
              Six buttons under the board: five icons and the word Hold. Hard drop stands apart.
            </p>
            <div className="reveal">
              <ControlPad />
            </div>
            <ul className="reveal-stagger flex max-w-2xl flex-col divide-y divide-line border-y border-line">
              {buttons.map((b) => (
                <li key={b.name} className="flex items-start gap-4 py-4">
                  <span className="flex w-28 flex-none gap-2 sm:w-36">
                    {b.controls.map((c) => (
                      <span key={c.id} className="chip">
                        <ControlGlyph control={c} />
                      </span>
                    ))}
                  </span>
                  <span className="flex flex-col gap-1 text-sm">
                    <span className="font-semibold">{b.name}</span>
                    <span className="text-text-muted">{b.text}</span>
                  </span>
                </li>
              ))}
            </ul>
            <p className="measure text-sm text-text-muted">
              Pause is in the top row of the screen, away from the thumbs. It offers Resume, End run
              and Menu. Leaving the app pauses the game.
            </p>
            <div className="flex flex-col gap-3">
              <p className="measure text-sm text-text-muted">
                Settings has two layout switches. Left-handed mirrors the buttons, as below. Large
                buttons scales the cluster up by 1.2.
              </p>
              <div className="reveal">
                <ControlPad mirrored />
              </div>
            </div>
          </section>

          <section
            id="pieces"
            data-s="2"
            aria-labelledby="pieces-h"
            className="htp-section flex scroll-mt-4 flex-col gap-6 pb-14 lg:pb-24"
          >
            <Heading id="pieces-h">Pieces</Heading>
            <p className="measure text-sm text-text-muted">
              Seven pieces, one color each. They come from a shuffled bag of seven: every piece
              appears once per bag, so a long streak of one piece cannot happen.
            </p>
            <ul className="reveal-stagger grid grid-cols-2 gap-x-6 gap-y-5 sm:grid-cols-4">
              {pieceRows.map(({ letter, piece }) => (
                <li key={letter} className="flex flex-col items-start gap-2">
                  <PieceSpecimen piece={piece} />
                  <span className="font-display text-lg uppercase">{letter}</span>
                </li>
              ))}
            </ul>
            <p className="measure text-sm text-text-muted">
              The colors differ in brightness as well as hue, so the pieces still tell apart without
              color. Here is the same row in grayscale, darkest to lightest on the dark ground.
            </p>
            <ul className="reveal flex flex-wrap gap-x-3 gap-y-3" aria-label="Pieces in grayscale">
              {grayOrder.map((piece) => (
                <li key={piece} className="flex flex-col items-start gap-1">
                  <PieceSpecimen piece={piece} gray />
                  <span className="font-display text-sm uppercase">{PIECE_LETTERS[piece]}</span>
                </li>
              ))}
            </ul>
          </section>

          <section
            id="scoring"
            data-s="3"
            aria-labelledby="scoring-h"
            className="htp-section flex scroll-mt-4 flex-col gap-6 pb-14 lg:pb-24"
          >
            <Heading id="scoring-h">Scoring</Heading>
            <p className="measure text-sm text-text-muted">
              A clear scores its base points times the level you are on when you clear. Dropping
              scores nothing.
            </p>
            <div className="reveal">
              <ScoreTable />
            </div>
            <dl className="reveal-stagger flex max-w-2xl flex-col gap-5 text-sm">
              <div className="flex flex-col gap-1">
                <dt className="font-semibold">Combo</dt>
                <dd className="text-text-muted">
                  Clear lines on locks in a row and each clear after the first adds {COMBO_BONUS} ×
                  combo × level. The first clear of a chain is combo 0 and adds nothing, the next is
                  combo 1, then 2. A lock that clears nothing ends the chain.
                </dd>
              </div>
              <div className="flex flex-col gap-1">
                <dt className="font-semibold">Back-to-back</dt>
                <dd className="text-text-muted">
                  A four-line clear right after another four-line clear scores{" "}
                  {BACK_TO_BACK_MULTIPLIER} × its base points. Clearing 1 to 3 lines ends the
                  streak. A lock that clears nothing does not.
                </dd>
              </div>
              <div className="flex flex-col gap-1">
                <dt className="font-semibold">T-spins</dt>
                <dd className="text-text-muted">No bonus. A T piece scores like any other.</dd>
              </div>
              <div className="flex flex-col gap-1">
                <dt className="font-semibold">Worked example</dt>
                <dd className="text-text-muted">
                  At level {example.level} a four-line clear is{" "}
                  {example.plain.toLocaleString("en-US")}. Straight after another four-line clear it
                  is {example.b2b.toLocaleString("en-US")}. If it is also the third clearing lock in
                  a row (combo 2), add {example.combo}:{" "}
                  {(example.b2b + example.combo).toLocaleString("en-US")}.
                </dd>
              </div>
            </dl>
          </section>

          <section
            id="levels"
            data-s="4"
            aria-labelledby="levels-h"
            className="htp-section flex scroll-mt-4 flex-col gap-6 pb-14 lg:pb-24"
          >
            <Heading id="levels-h">Levels and speed</Heading>
            <p className="measure text-sm text-text-muted">
              The level rises every {LINES_PER_LEVEL} cleared lines. Each level steps the piece down
              sooner.
            </p>
            <div className="reveal">
              <SpeedTable />
            </div>
            <ul className="reveal-stagger flex max-w-2xl flex-col gap-3 text-sm text-text-muted">
              <li>
                Marathon lets you start higher, at any level from 1 to {MAX_START_LEVEL} that you
                have unlocked. Level N opens when the lines you have cleared across all games reach{" "}
                {LINES_PER_LEVEL} × (N − 1). Level 1 is always open.
              </li>
              <li>
                A run keeps its start level until the line count catches up. Start at level 5 and
                you stay on 5 until 50 lines are cleared in that run.
              </li>
              <li>
                Points use the level, so a higher start scores more. The pace follows the level too.
              </li>
              <li>
                Play on the main menu starts at level 1, and so does every mode but Marathon. Play
                again repeats the run&apos;s start level.
              </li>
              <li>
                Start levels stop at {MAX_START_LEVEL}. The pace keeps rising until level 16, where
                it reaches the floor.
              </li>
            </ul>
          </section>

          <section
            id="hold"
            data-s="5"
            aria-labelledby="hold-h"
            className="htp-section flex scroll-mt-4 flex-col gap-6"
          >
            <Heading id="hold-h">Hold, next, lock delay</Heading>
            <dl className="reveal-stagger flex max-w-2xl flex-col gap-5 text-sm">
              <div className="flex flex-col gap-1">
                <dt className="font-semibold">Hold</dt>
                <dd className="text-text-muted">
                  The hold slot is top left and starts empty. Hold with an empty slot stashes the
                  piece and brings the next one. After that, Hold swaps, and the piece you take
                  comes back at the top in its first orientation. One swap per spawned piece: Hold
                  does nothing again until the next piece locks.
                </dd>
              </div>
              <div className="flex flex-col gap-1">
                <dt className="font-semibold">Next queue</dt>
                <dd className="text-text-muted">
                  The top right shows the next {NEXT_QUEUE_SIZE} pieces, in the order the bag deals
                  them.
                </dd>
              </div>
              <div className="flex flex-col gap-1">
                <dt className="font-semibold">Ghost</dt>
                <dd className="text-text-muted">
                  The empty frame is where the piece will land. It is on by default and has a switch
                  in Settings.
                </dd>
              </div>
            </dl>
            <div className="reveal">
              <GhostDiagram />
            </div>
            <p className="measure text-sm text-text-muted">
              A piece that has landed waits {LOCK_DELAY} s before it locks. A move or rotation that
              works restarts the wait, up to {MAX_LOCK_RESETS} times per piece. Stepping off a ledge
              so the piece falls again resets that count. Hard drop locks at once.
            </p>
            <LockTimeline />
          </section>
        </div>
      </div>

      <section className="wrap flex flex-wrap items-center gap-x-6 gap-y-3 border-t border-line pt-10 pb-20 lg:pt-16 lg:pb-28">
        <a
          href={downloadUrl}
          className="btn-primary px-5 py-3 text-sm font-semibold lg:px-6 lg:py-4 lg:text-base"
        >
          Get the latest build
        </a>
        <Link href="/modes" className="link-quiet py-2 text-sm">
          Modes
        </Link>
      </section>
    </PageShell>
  );
}
