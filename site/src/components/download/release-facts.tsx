import { day, megabytes, type Release } from "@/lib/releases";

/** Tag, date, APK file name and size for one release. */
export function ReleaseFacts({ release }: { release: Release }) {
  const rows: [string, string][] = [
    ["Version", release.tag],
    ["Published", day(release.published)],
  ];
  if (release.apk) {
    rows.push(["File", release.apk.name], ["Size", megabytes(release.apk.size)]);
  }
  return (
    <dl className="grid grid-cols-[6rem_1fr] gap-y-2 text-sm">
      {rows.map(([k, v]) => (
        <div key={k} className="contents">
          <dt className="text-text-faint">{k}</dt>
          <dd className="break-all">{v}</dd>
        </div>
      ))}
    </dl>
  );
}
