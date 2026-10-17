import type { Metadata } from "next";
import { ChangelogEntry } from "@/components/download/changelog-entry";
import { ReleaseFacts } from "@/components/download/release-facts";
import { GameScreen } from "@/components/screens/game-screen";
import { PageShell } from "@/components/page-shell";
import { PhoneFrame } from "@/components/phone-frame";
import { downloadUrl, repo } from "@/lib/links";
import { day, fetchReleases } from "@/lib/releases";

export const revalidate = 3600;

export const metadata: Metadata = {
  title: "Download",
  description: "Download the DropGrid APK for Android, with install steps and release notes.",
  alternates: { canonical: "/download" },
};

const steps = [
  "Download the APK on your phone.",
  "Open it from your browser's downloads or a file manager.",
  "If Android asks, allow installs from that app.",
  "Tap Install.",
];

export default async function Download() {
  const releases = await fetchReleases();
  const newest = releases?.versions[0] ?? null;
  const rolling = releases?.rolling ?? null;
  const primary = newest?.apk?.url ?? downloadUrl;
  const history = releases?.versions.slice(0, 6) ?? [];

  return (
    <PageShell current="/download">
      <div className="wrap grid gap-10 pt-6 pb-20 lg:grid-cols-[1fr_22rem] lg:gap-20">
        <div className="flex min-w-0 flex-col gap-14">
          <section className="flex flex-col gap-6">
            <h1 className="font-display text-3xl lg:text-5xl">Download</h1>
            {newest ? (
              <ReleaseFacts release={newest} />
            ) : (
              <p className="text-sm text-text-muted">
                Release details could not be loaded. This page refreshes every hour.
              </p>
            )}
            <div className="flex flex-wrap items-center gap-x-6 gap-y-3">
              <a
                href={primary}
                className="btn-primary px-5 py-3 text-sm font-semibold lg:px-6 lg:py-4 lg:text-base"
              >
                {newest?.apk ? `Download ${newest.tag}` : "Download from GitHub"}
              </a>
              <a href={`${repo}/releases`} className="link-quiet py-2 text-sm">
                All releases
              </a>
            </div>
            <p className="text-sm text-text-muted">
              Android only. Builds are debug-signed APKs, not a Play Store release.
            </p>
          </section>

          <section className="reveal flex flex-col gap-4">
            <h2 className="font-display text-2xl">Install</h2>
            <ol className="flex flex-col divide-y divide-line border-y border-line text-sm">
              {steps.map((s, i) => (
                <li key={s} className="flex gap-4 py-3">
                  <span className="w-4 shrink-0 text-text-faint tabular-nums">{i + 1}</span>
                  <span>{s}</span>
                </li>
              ))}
            </ol>
          </section>

          {rolling ? (
            <section className="reveal flex flex-col gap-4">
              <h2 className="font-display text-2xl">Rolling build</h2>
              <p className="text-sm text-text-muted">
                Rebuilt on every push to main. Not a versioned release.
              </p>
              <div className="flex flex-col gap-1 text-sm">
                <span>{rolling.title}</span>
                <span className="text-xs text-text-faint">
                  {rolling.apk ? `${rolling.apk.name}, ` : ""}
                  {day(rolling.published)}
                </span>
              </div>
              <div>
                <a href={rolling.apk?.url ?? rolling.url} className="link-quiet py-2 text-sm">
                  {rolling.apk ? "Download the rolling build" : "Open the rolling build"}
                </a>
              </div>
            </section>
          ) : null}

          {history.length > 0 ? (
            <section className="flex flex-col gap-2">
              <h2 className="font-display text-2xl">Changelog</h2>
              <ul className="flex flex-col divide-y divide-line border-y border-line">
                {history.map((r) => (
                  <ChangelogEntry key={r.tag} release={r} />
                ))}
              </ul>
            </section>
          ) : null}
        </div>
        <div className="hidden lg:block">
          <div className="sticky top-6 flex flex-col gap-3">
            <PhoneFrame className="phone-hover max-w-[16rem]">
              <GameScreen />
            </PhoneFrame>
            <p className="text-xs text-text-faint">The play screen in the app.</p>
          </div>
        </div>
      </div>
    </PageShell>
  );
}
