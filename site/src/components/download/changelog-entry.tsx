import { day, type Release } from "@/lib/releases";

/** One past release: tag, date, and its notes as plain text. */
export function ChangelogEntry({ release }: { release: Release }) {
  return (
    <li className="reveal flex flex-col gap-2 py-5">
      <div className="flex flex-wrap items-baseline gap-x-4 gap-y-1">
        <a href={release.url} className="link-quiet font-semibold">
          {release.tag}
        </a>
        <span className="text-xs text-text-faint">{day(release.published)}</span>
      </div>
      {release.notes ? (
        <p className="text-sm break-words whitespace-pre-wrap text-text-muted [overflow-wrap:anywhere]">
          {release.notes}
        </p>
      ) : null}
    </li>
  );
}
