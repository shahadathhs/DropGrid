# site — Agent Instructions (marketing site)

Next.js 15 static marketing page for DropGrid, deployed on Vercel. Inherits
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
- One radius: `--radius-cell` (4px, `rounded-cell`). No other radius.
- Fonts are the game's two OFL monos via `next/font/local`:
  Martian Mono (`--font-mono`) for body/UI, Departure Mono (`--font-display`)
  for the wordmark and display numbers.
- One primary button per screenful: filled ink (`bg-accent text-accent-ink`).
  Secondaries are quiet text links, not outlined buttons.
- Copy is game voice: short declaratives. No taglines, no exclamation
  marks, no questions to the player, no emoji.
- Motion: nothing loops. A one-shot animation must be ≤ 250ms and earn its
  place. No animation libraries.

## Code structure

- One exported React component per file, kebab-case file names.
- `src/lib/` is small files by concern (`cn`, `tokens`, `links`).
- No client components unless strictly needed; the page must render with
  JS disabled.

## Quality

- Lint is **oxlint with type-aware rules** (`oxlint-tsgolint`) + prettier. There is **no eslint** — typescript-eslint cannot parse TypeScript 7 (no JS compiler API), the same reason type checking uses the native `tsc`.
- After every change: `make site-lint && make site-typecheck && make site-build`.
- Commits follow Conventional Commits; the git hooks live at the **repo root** (`.husky/`, `commitlint.config.mjs`, `.lintstagedrc`) and cover the whole repo. The full type-aware lint runs here via `make site-lint`.
- Before shipping: check the anti-slop list (root AGENTS.md) on the
  rendered page, both grounds.
