import { repo } from "@/lib/links";

const releasesApi = "https://api.github.com/repos/shahadathhs/DropGrid/releases";

export type Release = {
  tag: string;
  title: string;
  published: string;
  notes: string;
  url: string;
  apk: { name: string; size: number; url: string } | null;
};

export type Releases = {
  /** Versioned releases (v*), newest first. */
  versions: Release[];
  /** The rolling "latest" build the pipeline refreshes on every main push. */
  rolling: Release | null;
};

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null;
}

function parseRelease(raw: unknown): Release | null {
  if (!isRecord(raw)) return null;
  const { tag_name, name, published_at, body, html_url, assets } = raw;
  if (typeof tag_name !== "string" || typeof published_at !== "string") return null;
  if (raw.draft === true || raw.prerelease === true) return null;
  let apk: Release["apk"] = null;
  if (Array.isArray(assets)) {
    for (const asset of assets as unknown[]) {
      if (!isRecord(asset)) continue;
      const { name: file, size, browser_download_url } = asset;
      if (
        typeof file === "string" &&
        file.endsWith(".apk") &&
        typeof size === "number" &&
        typeof browser_download_url === "string" &&
        browser_download_url.startsWith(`${repo}/releases/download/`)
      ) {
        apk = { name: file, size, url: browser_download_url };
        break;
      }
    }
  }
  return {
    tag: tag_name,
    title: typeof name === "string" && name ? name : tag_name,
    published: published_at,
    notes: typeof body === "string" ? body.trim() : "",
    url: typeof html_url === "string" && html_url.startsWith(repo) ? html_url : `${repo}/releases`,
    apk,
  };
}

/**
 * The repository's releases, or null on any failure (rate limit 403/429, network,
 * timeout, bad shape). Never throws.
 */
export async function fetchReleases(): Promise<Releases | null> {
  try {
    const res = await fetch(`${releasesApi}?per_page=30`, {
      headers: { Accept: "application/vnd.github+json" },
      next: { revalidate: 3600 },
      signal: AbortSignal.timeout(10000),
    });
    if (!res.ok) return null;
    const body: unknown = await res.json();
    if (!Array.isArray(body)) return null;
    const all = (body as unknown[]).flatMap((r) => parseRelease(r) ?? []);
    const versions = all
      .filter((r) => /^v\d/.test(r.tag))
      .sort((a, b) => Date.parse(b.published) - Date.parse(a.published));
    return { versions, rolling: all.find((r) => r.tag === "latest") ?? null };
  } catch {
    return null;
  }
}

/** 29964269 -> "30.0 MB" */
export function megabytes(bytes: number): string {
  return `${(bytes / 1_000_000).toFixed(1)} MB`;
}

/** "2026-10-17T05:28:38Z" -> "17 Oct 2026" (UTC) */
export function day(iso: string): string {
  return new Date(iso).toLocaleDateString("en-GB", {
    day: "numeric",
    month: "short",
    year: "numeric",
    timeZone: "UTC",
  });
}
