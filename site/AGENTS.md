# site — Agent Instructions (marketing site)

Next.js 16 static marketing page for DropGrid, deployed on Vercel. Inherits
the root `AGENTS.md` and the visual rules in `docs/README_VISUAL_DESIGN.md`.
This file adds site-specific hard rules. Conflicts resolve in favor of the
design docs.

## Design implementation

- The game's palette is law: `game/scripts/palette.gd` defines every color.
  `src/app/globals.css` mirrors it as CSS custom properties (two grounds:
  graphite default, paper via `.light`); `src/lib/tokens.ts` mirrors the
  few values components need inline. When the palette changes in the game,
  copy the change here in the same change. The site never invents a color,
  font, or radius.
- One radius: `--radius-cell` (4px, `rounded-cell`). No other radius. One
  exemption: the phone bezel (the device chrome around a screen, `PhoneFrame`)
  is hardware, not UI, so its corners may be rounder. Everything inside the
  screen uses `--radius-cell` only.
- Fonts are the game's two OFL monos via `next/font/local`:
  Martian Mono (`--font-mono`) for body/UI, Departure Mono (`--font-display`)
  for the wordmark and display numbers.
- One primary button per screenful: filled ink (`bg-accent text-accent-ink`).
  Secondaries are quiet text links, not outlined buttons.
- Copy is game voice: short declaratives. No taglines, no exclamation
  marks, no questions to the player, no emoji.
- Motion: nothing loops. Time-based animations stay one-shot, 250ms or less,
  and must earn their place. Scroll-linked animation (CSS `animation-timeline:
view()` or `scroll()`, progress-driven by scroll position, never
  autoplaying, never looping) is allowed and may span any scroll distance. It
  must be wrapped in `@supports (animation-timeline: view())` so browsers
  without support see a complete static page, and be disabled under
  `prefers-reduced-motion: reduce`. No animation libraries, and no JavaScript
  is required for any content or motion. Hover transitions are 150ms or less
  and change only color, border, opacity, or transform. The utilities live in
  `src/app/motion.css`.
- One user-started interactive island: /play embeds the game's Web export in an
  iframe that loads only after the visitor presses Play (a plain link inside the
  iframe's poster). No autoplay, no client JavaScript of ours, and the page is
  complete without it.

## Code structure

- One exported React component per file, kebab-case file names.
- `src/lib/` is small files by concern (`cn`, `tokens`, `links`).
- No client components unless strictly needed; the page must render with
  JS disabled. The one interactive island is /play (see Motion above).
- `public/play/` is the game's Web export, fetched at build time by
  `scripts/fetch-playground.mjs` (never committed, gitignored). The script never
  fails the build; `/play` shows an unavailable state when the files are absent.

## Quality

- Lint is **oxlint with type-aware rules** (`oxlint-tsgolint`) + prettier. There is **no eslint** — typescript-eslint cannot parse TypeScript 7 (no JS compiler API), the same reason type checking uses the native `tsc`.
- After every change: `make site-lint && make site-typecheck && make site-build`.
- Commits follow Conventional Commits; the git hooks live at the **repo root** (`.husky/`, `commitlint.config.mjs`, `.lintstagedrc`) and cover the whole repo. The full type-aware lint runs here via `make site-lint`.
- Before shipping: check the anti-slop list (root AGENTS.md) on the
  rendered page, both grounds.

<!-- BEGIN:nextjs-agent-rules -->

## This is NOT the Next.js you know

This version has breaking changes — APIs, conventions, and file structure may all differ from your training data. Read the relevant guide in `node_modules/next/dist/docs/` (resolved from this file's directory; in monorepos the `next` package may not be visible from the repo root) before writing any code. Heed deprecation notices.

This block is written and re-added by `next dev` — verify at `node_modules/next/dist/server/lib/generate-agent-files.js`. Removing it from a diff only re-creates the uncommitted change; committing it with your work keeps the tree clean.

<!-- END:nextjs-agent-rules -->
