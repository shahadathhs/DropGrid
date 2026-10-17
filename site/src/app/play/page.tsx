import type { Metadata } from "next";
import { existsSync } from "node:fs";
import { join } from "node:path";
import { PageShell } from "@/components/page-shell";
import { PhoneFrame } from "@/components/phone-frame";
import { Playground } from "@/components/play/playground";
import { downloadUrl } from "@/lib/links";

export const metadata: Metadata = {
  title: "Play",
  description: "Play DropGrid in your browser with the keyboard. Nothing is saved or sent.",
  alternates: { canonical: "/play" },
};

const keys = [
  { keys: "Left or A", action: "Move left" },
  { keys: "Right or D", action: "Move right" },
  { keys: "Down or S", action: "Soft drop" },
  { keys: "Up or X", action: "Rotate" },
  { keys: "C or Shift", action: "Hold" },
  { keys: "Space", action: "Hard drop" },
  { keys: "P or Escape", action: "Pause" },
];

/** Checked at build time: the export is fetched into public/ by the prebuild script. */
const hasGame = existsSync(join(process.cwd(), "public", "play", "game", "index.html"));

export default function Play() {
  return (
    <PageShell current="/play">
      <div className="wrap flex flex-col gap-6 pt-6 pb-20">
        <h1 className="font-display text-3xl lg:text-5xl">Play</h1>
        {hasGame ? (
          <div className="flex flex-col gap-8 lg:flex-row lg:items-start lg:gap-20">
            <PhoneFrame decorative={false} className="max-w-[23.6rem] lg:shrink-0">
              <Playground />
            </PhoneFrame>
            <div className="reveal flex max-w-sm flex-col gap-6">
              <table className="w-full text-sm">
                <caption className="pb-3 text-left font-display text-2xl">Keys</caption>
                <tbody className="divide-y divide-line border-y border-line">
                  {keys.map((k) => (
                    <tr key={k.action}>
                      <th scope="row" className="w-1/2 py-2 pr-3 text-left font-normal">
                        {k.keys}
                      </th>
                      <td className="py-2 text-text-muted">{k.action}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
              <p className="text-sm text-text-muted">
                Nothing on this page is saved or sent anywhere. The browser version runs as a guest,
                with no storage and no network.
              </p>
            </div>
          </div>
        ) : (
          <>
            <p className="text-sm text-text-muted">
              The browser version is not available in this build.
            </p>
            <div>
              <a
                href={downloadUrl}
                className="btn-primary inline-block px-5 py-3 text-sm font-semibold lg:px-6 lg:py-4 lg:text-base"
              >
                Get the latest build
              </a>
            </div>
          </>
        )}
      </div>
    </PageShell>
  );
}
