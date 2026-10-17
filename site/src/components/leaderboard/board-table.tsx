import type { Row } from "@/lib/leaderboard";

/**
 * One board as a table. `rows` is null when the API could not be read. Order is
 * the server's; the top three differ by weight only.
 */
export function BoardTable({
  id,
  name,
  note,
  unit,
  rows,
}: {
  id: string;
  name: string;
  note: string;
  unit: string;
  rows: Row[] | null;
}) {
  return (
    <section id={id} aria-labelledby={`${id}-h`} className="lb-section flex flex-col gap-3">
      <div className="flex flex-col gap-1">
        <h2 id={`${id}-h`} className="font-display text-2xl">
          {name}
        </h2>
        <p className="text-sm text-text-muted">{note}</p>
      </div>
      {rows === null ? (
        <p className="border-t border-line pt-4 text-sm text-text-muted">
          Scores could not be loaded. This page refreshes every hour.
        </p>
      ) : rows.length === 0 ? (
        <p className="border-t border-line pt-4 text-sm text-text-muted">No scores yet</p>
      ) : (
        <table className="lb-table w-full border-collapse text-sm">
          <thead>
            <tr className="text-left text-xs text-text-faint">
              <th scope="col" className="w-14 py-2 font-normal">
                Rank
              </th>
              <th scope="col" className="py-2 font-normal">
                Player
              </th>
              <th scope="col" className="py-2 text-right font-normal">
                {unit}
              </th>
            </tr>
          </thead>
          <tbody className="reveal-stagger">
            {rows.map((row) => (
              <tr
                key={`${row.rank}-${row.username}`}
                className="lb-row border-t border-line"
                data-top={row.rank <= 3 ? "" : undefined}
              >
                <td className="py-3 tabular-nums">{row.rank}</td>
                <td className="max-w-0 truncate py-3 pr-4">{row.username}</td>
                <td className="py-3 text-right tabular-nums">{row.value}</td>
              </tr>
            ))}
          </tbody>
        </table>
      )}
    </section>
  );
}
