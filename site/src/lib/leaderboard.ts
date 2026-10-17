import { apiBase } from "@/lib/links";

/** The ranked boards, in the order the game lists them (game_mode.gd CATEGORIES). */
export const boards = [
  { id: "marathon", name: "Marathon", period: "all", note: "Best score, all time." },
  { id: "sprint", name: "Sprint", period: "all", note: "Time to clear 40 lines. Lower is better." },
  { id: "ultra", name: "Ultra", period: "all", note: "Best score in two minutes." },
  { id: "daily", name: "Daily", period: "today", note: "Best score today. Resets at 00:00 UTC." },
] as const;

export type BoardId = (typeof boards)[number]["id"];

export type Row = { rank: number; username: string; value: string };

/** 1234567 -> "1,234,567" (UiFormat.thousands in the game). */
export function thousands(value: number): string {
  return String(Math.abs(value)).replace(/\B(?=(\d{3})+(?!\d))/g, ",");
}

/** 83000 -> "1:23" (UiFormat.clock in the game). */
export function clock(ms: number): string {
  const total = Math.floor(ms / 1000);
  return `${Math.floor(total / 60)}:${String(total % 60).padStart(2, "0")}`;
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null;
}

/**
 * One board from `GET /v1/leaderboard?category=&period=`, or null when it could
 * not be read. Never throws: the build and every revalidation must survive a
 * sleeping or broken API. Order and ties are the server's.
 *
 * The server echoes `category` (backend/modules/scores/schemas.py). An older
 * deployment ignores the parameter and returns only the marathon board as
 * `best_score` rows; such a reply is accepted for marathon and refused for
 * every other board, so one board is never shown under another's name.
 */
export async function fetchBoard(id: BoardId): Promise<Row[] | null> {
  const board = boards.find((b) => b.id === id);
  if (!board) return null;
  try {
    const url = `${apiBase}/v1/leaderboard?category=${id}&period=${board.period}`;
    const res = await fetch(url, {
      headers: { Accept: "application/json" },
      next: { revalidate: 3600 },
      signal: AbortSignal.timeout(10000),
    });
    if (!res.ok) return null;
    const body: unknown = await res.json();
    if (!isRecord(body) || !Array.isArray(body.entries)) return null;
    if (body.category !== undefined && body.category !== id) return null;
    if (body.category === undefined && id !== "marathon") return null;
    const rows: Row[] = [];
    for (const entry of body.entries as unknown[]) {
      if (!isRecord(entry)) return null;
      const { rank, username } = entry;
      if (typeof rank !== "number" || typeof username !== "string") return null;
      if (id === "sprint") {
        if (typeof entry.duration_ms !== "number") return null;
        rows.push({ rank, username, value: clock(entry.duration_ms) });
      } else {
        const score = entry.score ?? entry.best_score;
        if (typeof score !== "number") return null;
        rows.push({ rank, username, value: thousands(score) });
      }
    }
    return rows;
  } catch {
    return null;
  }
}
