// Fetches the game's web export into public/play/game/ before dev and build.
// The export is a release asset (CI attaches dropgrid-web.tar.gz to the rolling
// "latest" release), so the repo never holds it. This script never fails the
// build: if the asset is missing, the network is down, or tar is not installed,
// it prints one warning and exits 0, and /play shows its unavailable state.
// A local export (index.html already there) wins; FORCE=1 fetches again.
import { execFileSync } from "node:child_process";
import { existsSync, mkdirSync, mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const url = "https://github.com/shahadathhs/DropGrid/releases/download/latest/dropgrid-web.tar.gz";
const target = join(dirname(fileURLToPath(import.meta.url)), "..", "public", "play", "game");

if (existsSync(join(target, "index.html")) && process.env.FORCE !== "1") {
  console.log("fetch-playground: public/play/game/ already has a build; leaving it.");
  process.exit(0);
}

let scratch;
try {
  const res = await fetch(url, { redirect: "follow", signal: AbortSignal.timeout(120_000) });
  if (!res.ok) throw new Error(`HTTP ${res.status}`);
  scratch = mkdtempSync(join(tmpdir(), "dropgrid-web-"));
  const archive = join(scratch, "dropgrid-web.tar.gz");
  writeFileSync(archive, Buffer.from(await res.arrayBuffer()));
  rmSync(target, { recursive: true, force: true });
  mkdirSync(target, { recursive: true });
  execFileSync("tar", ["-xzf", archive, "-C", target], { stdio: "pipe" });
  if (!existsSync(join(target, "index.html"))) throw new Error("archive has no index.html");
  console.log("fetch-playground: game build installed in public/play/game/.");
} catch (err) {
  rmSync(target, { recursive: true, force: true });
  const why = err instanceof Error ? err.message : String(err);
  console.warn(`fetch-playground: skipped (${why}). /play will show the unavailable state.`);
} finally {
  if (scratch) rmSync(scratch, { recursive: true, force: true });
}
process.exit(0);
