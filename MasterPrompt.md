# DropGrid — Visual Redesign Brief

You are redesigning the interface of DropGrid, a portrait falling-block puzzle game for Android, built with Godot 4 and GDScript. The game already works. Your job is to give it a real identity.

The goal is a game that looks like a person with taste made it on purpose. The current build looks like a generated web dashboard with a game inside it. This brief explains why, what to do instead, and how to prove it worked.

---

## 1. Read before you touch anything

The project already exists. Do not rebuild it from scratch, and do not invent a parallel system.

| File | What it is |
|---|---|
| `docs/README_PROJECT_OVERVIEW.md` | Scope. What v1 includes and what it must never include. |
| `docs/README_GAMEPLAY_FEATURES.md` | Rules, controls, scoring. Do not change gameplay. |
| `docs/README_VISUAL_DESIGN.md` | The current visual spec. You will rewrite it to match your new system. |
| `game/scripts/palette.gd` | All color tokens. The only place colors are defined. |
| `game/scripts/game_theme.gd` | The one shared Theme. Every style comes from here through `theme_type_variation`. |
| `game/scripts/board_view.gd` | Custom drawing of the board, ghost piece, and active piece. |
| `game/scenes/*.tscn` | Main menu, game, pause, game over, leaderboard, levels. Sign-in, profile, and settings are built in scripts. |
| `game/assets/icons/*.svg` | The current icon set. |
| `ref/*.png` | Visual references. See section 3. |

The board is 10 × 20. The viewport is 720 × 1280, with stretch mode `canvas_items` and aspect `expand`.

Keep the architecture: the model, controller, view, and input stay separate. Colors live only in `Palette`. Styles live only in `GameTheme`. No scene sets its own colors or fonts inline.

---

## 2. What is wrong now (be specific, these are the slop signals)

Fix each of these. They are why the game reads as generated:

1. **It is a web page.** The tokens were ported from a Next.js CSS prototype (`UI_SCALE := 1.5` "CSS px"). There are eyebrows, cards, pills, avatars, and segmented controls. Those are web SaaS components, not game components.
2. **Two-tone accent headlines.** "Find your / *flow.*", "Who's / *on top?*", "Welcome / *back.*" This is the most recognizable AI landing-page pattern. Remove all of them.
3. **Tagline copy.** "Stack smart. Clear lines. Beat your best.", "Take a breath.", "Nice run.", "One more?" This is motivational filler. Games label things; they do not narrate to the player.
4. **The default dark-dashboard palette.** A blue-black background, periwinkle accent `#7C9CFF`, and mint success color are the median "modern dark UI." Nothing about it is specific to this game.
5. **No typographic identity.** It uses the system font with fake bold (`variation_embolden`). Score digits are not tabular, so they jitter as they change.
6. **Card soup.** StatCard, StrongCard, IconTile, SettingIcon, and AvatarCircle are boxes inside boxes, each with a 2 px border.
7. **Decorative icons.** `sparkles.svg` has no meaning in a block game.
8. **Fake progression decoration.** The levels screen is a "level path" of locked nodes styled like a mobile saga map. In MVP1 it becomes a plain start-level picker (see `docs/MVP1_PLAN.md`): design it as a simple choice of starting speed, not a journey.

---

## 3. References: what to take, what to reject

Do not average the references. Take a specific idea from each one and say which one you took.

- **`ref/4.png`, `ref/6.png` (Blockfall gameplay).** Take: the board fills the width; the HUD is a single row of equal tiles; cells are flat with a light grid; the ghost piece is an outline; muted piece colors still read clearly. Reject: the right-hand column that steals board width; HOLD (not in our scope); the duplicated TIME tile.
- **`ref/8.png` (Blockfall menu).** Take: a hero object built from the game's own pieces, and a wordmark with real character (pixel lettering). Reject: three equal-weight pastel buttons with no clear primary action.
- **`ref/3.png` (Blockfall pause).** Take: one filled primary button with outlined secondaries; the game dimmed behind; a big confident title. Copy this hierarchy.
- **`ref/5.png`, `ref/1.png` (Blockfall settings).** Take: grouped sections with plain labels and toggles aligned right. Reject: a heavy bordered card per group. Use spacing and a section label instead of a box.
- **`ref/2.png` (Blockfall themes).** Take: the idea that a palette is a named, coherent set ("Charcoal / Bone"). Do not build a theme picker in v1.
- **`ref/7.png` (Blockfall modes).** Reject: frosted glass over a blurred 3D render. This is exactly what to avoid.
- **`ref/9.png` (dark minimal board).** Take: empty cells drawn as slightly lighter rounded tiles, so the empty board has texture without grid lines; earthy, non-neon piece colors; the score is just a number.
- **`ref/10.png` (jewel-block game).** **Anti-reference.** Beveled gem blocks, neon border glow, sparkle particles, coin counter, saturated blue gradient. If anything you make looks like this, you have gone the wrong way.
- **`ref/11.png` (Two Dots).** Take: flat, confident color; generous negative space; a big number with a small label ("30 / MOVES"); large shapes that carry the brand instead of decoration.

---

## 4. The design system you must produce

Decide each item. Write down the reasoning in one sentence each. "Modern and clean" is not a reason.

1. **One concept, in one sentence.** For example: "The grid is the brand: every UI element is built on the board's cell unit." or "A printed puzzle book: paper, ink, and flat color." The concept must decide later questions for you.
2. **Direction: light or dark.** The docs say dark. The strongest references (Blockfall) are warm and light. Build the gameplay screen in both (section 6, phase 2) and let the user choose. Do not pick silently.
3. **Unit and spacing.** Derive spacing from the cell size (for example, cell = 8 units, gaps = 1 unit). Use one spacing scale with at most 5 steps. No arbitrary values.
4. **Color.** At most: 2 background levels, 1 line color, 2 text levels, 1 accent, 1 danger, and 7 piece colors. Piece colors must be told apart in grayscale and for deuteranopia; check this and report it. Every color goes in `palette.gd`. Delete tokens nothing uses.
5. **Type.** Bundle one real font in `game/assets/fonts/` with an OFL or similarly open license, and record the license in the repo. It must have real bold and tabular numerals. One family, two weights. Optionally add a second face for the wordmark and the big score only. Candidates to judge, not defaults: IBM Plex Sans + Plex Mono, Chivo + Chivo Mono, Space Mono, Martian Mono, Departure Mono, a pixel face for the wordmark. Avoid Inter and Poppins; they are the generic default.
6. **Type scale.** At most 5 sizes. The score is the largest number on the gameplay screen.
7. **Shape.** One corner radius for controls and one for cells (it can be 0). Never pill shapes, except toggles.
8. **Cell rendering.** Define how empty, filled, ghost, active, and clearing cells look. This is the most important visual decision in the game and should take more effort than any menu.
9. **Buttons.** Exactly three: primary (filled), secondary (outlined or tinted), and text. Plus the gamepad buttons. Every screen has exactly one primary.
10. **Icons.** One stroke width, one style, one grid. Redraw or replace any that do not match. No emoji, no sparkles.
11. **Motion.** List every animation with a duration and a reason: lock, line clear, level up, score tick, button press, overlay in/out, game over. Nothing over 250 ms, except game over. Nothing loops at idle.
12. **Copy voice.** Short labels, the way a game would say them: "Paused", "Game over", "Best", "Play again". No taglines, no questions to the player, no exclamation marks, no two-tone headlines.

---

## 5. Screens

The gameplay screen comes first and gets the most care. Everything else is derived from it.

1. **Gameplay.** The board takes at least 85% of the screen width at 390 × 844. HUD: score (dominant), level, lines, next piece, pause. Gamepad: left, right, rotate, soft drop, hard drop. Touch targets at least 48 dp, and hard drop placed so it is hard to hit by accident. Safe area is respected.
2. **Pause overlay.** The board is dimmed but visible. Resume (primary), Restart, Settings, Quit to menu.
3. **Game over.** Final score, best score, and a clear "new best" state without confetti. Play again (primary), Menu.
4. **Main menu.** Wordmark plus one hero element made from game pieces. Play (primary), best score, and a quiet entry to leaderboard, settings, and account.
5. **Settings.** Sound, haptics, and only settings that are actually implemented.
6. **Leaderboard.** Rank, name, score, and a highlighted current player. Loading, empty, offline, and error states each get a designed state, not just text in a box.
7. **Sign in / profile.** Plain forms. Guest play is presented as the normal path, not a downgrade.
8. **Start level.** Levels 1–10; locked ones visibly unavailable; one tap starts the game. No map, no path, no stars.

---

## 6. Process (stop at each gate)

**Phase 1: Analysis. No code.**
Write `docs/design/01-analysis.md`. Include: the slop list from section 2 confirmed against the actual code (file and line), what you take from each reference, and the concept with two alternatives. **Stop and wait for the user to choose a concept.**

**Phase 2: Two directions, one screen each.**
Build the gameplay screen in the light and dark variants of the chosen concept: same layout, different palette. Take screenshots (see section 7). **Stop and show them side by side with `ref/4.png` and `ref/9.png`. Wait for the user to choose.**

**Phase 3: System.**
Rewrite `palette.gd`, `game_theme.gd`, and `docs/README_VISUAL_DESIGN.md` so the three agree. Remove dead theme variations and dead tokens. Bundle the font.

**Phase 4: Gameplay screen, final.**
Implement it fully, including every cell state and every animation. Screenshot it at every size in section 7. Critique your own screenshots against section 8 in writing, fix what fails, and screenshot again. **Stop for review.**

**Phase 5: Remaining screens.**
Pause, game over, menu, settings, leaderboard, account. These are built only from existing theme variations. If a screen needs a new variation, add it to the theme and say why. Take screenshots of all of them.

Do not move to the next phase without the user's approval at a gate. Do not design screens in isolation; each one must reuse the gameplay screen's parts.

---

## 7. Verification

You cannot judge a design you have not seen. Code that "should look right" does not count.

- Add a debug-only screenshot path: run with a command-line argument (for example `-- --shot=<path>`). After 2 frames, save `get_viewport().get_texture().get_image()` to a PNG and quit. Keep it out of release builds.
- Capture each screen at **390 × 844** (typical phone), **360 × 640** (short), and **412 × 915** (tall). Use a board state with pieces, a ghost, and a non-zero score, not an empty board.
- Look at each screenshot yourself before you report. List what is wrong.
- Run `make test` after each phase. Gameplay tests must keep passing.
- After code changes, run `depot/scripts/graphify-bg.sh` in the background.

---

## 8. Acceptance checklist

Report each item as pass or fail, with the screenshot that proves it.

- [ ] Cover the logo: could this be any other app? If yes, fail.
- [ ] Squint at the gameplay screenshot: the board and the active piece are the first things you see, and the score is the second.
- [ ] No two-tone headline, tagline, eyebrow label, glow, gradient, glass, or particle anywhere.
- [ ] No card inside a card. No border used where spacing would do.
- [ ] One primary button per screen.
- [ ] Score digits do not shift width as they change.
- [ ] Piece colors are distinguishable in a grayscale screenshot.
- [ ] Every color comes from `Palette`, and every style from `GameTheme`; grep for `Color(` in `scenes/` and in scripts other than the palette.
- [ ] Layout holds at all three sizes with no overlap and no stretched board.
- [ ] `docs/README_VISUAL_DESIGN.md` matches the code exactly.
- [ ] Nothing was added that the overview's "do not include" list forbids.

---

## Rules

- Change appearance, not gameplay. If a visual change requires a gameplay change, ask first.
- Prefer deleting to adding. A design gets better when parts are removed.
- When unsure between two options, build both small and show them; do not ask in the abstract.
- Report honestly. If a screenshot looks generic, say so.
