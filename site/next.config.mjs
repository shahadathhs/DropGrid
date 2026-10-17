// Plain JS on purpose — config stays trivial. Next 16.2.11+ supports
// TypeScript 7 (native); type checking runs in the build and separately
// via `pnpm typecheck`. The "@" alias comes from tsconfig.json paths.
// NEXT_DIST_DIR lets parallel builds and dev servers use separate output folders.
const nextConfig = { distDir: process.env.NEXT_DIST_DIR || ".next" };

export default nextConfig;
