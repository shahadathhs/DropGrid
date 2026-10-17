/** Primary navigation, in header order. */
export const navLinks = [
  { href: "/modes", label: "Modes" },
  { href: "/how-to-play", label: "How to play" },
  { href: "/leaderboard", label: "Leaderboard" },
  { href: "/download", label: "Download" },
] as const;

/** Every route the sitemap lists. */
export const sitemapRoutes = [
  "/",
  "/modes",
  "/how-to-play",
  "/leaderboard",
  "/download",
  "/privacy",
  "/contact",
] as const;
