// Plain JS on purpose — config stays trivial. Next 16.2.11+ supports
// TypeScript 7 (native); type checking runs in the build and separately
// via `pnpm typecheck`. The "@" alias comes from tsconfig.json paths.
// NEXT_DIST_DIR lets parallel builds and dev servers use separate output folders.
// /play/game/ is the game's web export (fetched at build time); it changes only when
// the site is rebuilt, so a short browser cache with a long stale window is enough.
const nextConfig = {
  distDir: process.env.NEXT_DIST_DIR || ".next",
  async headers() {
    return [
      {
        source: "/play/game/:path*",
        headers: [
          {
            key: "Cache-Control",
            value: "public, max-age=3600, stale-while-revalidate=86400",
          },
        ],
      },
    ];
  },
};

export default nextConfig;
