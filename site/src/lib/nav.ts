/** Primary navigation, in header order. */
export const navLinks = [
  { href: "/modes", label: "Modes" },
  { href: "/how-to-play", label: "How to play" },
  { href: "/play", label: "Play" },
  { href: "/leaderboard", label: "Leaderboard" },
  { href: "/download", label: "Download" },
] as const;

/** Every route the sitemap lists. */
export const sitemapRoutes = [
  "/",
  "/modes",
  "/how-to-play",
  "/play",
  "/leaderboard",
  "/download",
  "/privacy",
  "/contact",
] as const;
