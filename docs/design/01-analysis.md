# Phase 1: Analysis

Scope: MasterPrompt.md, Phase 1. No code was changed. Screen set is the MVP1 set from `docs/MVP1_PLAN.md` (the Levels screen becomes a plain start-level picker, levels 1 to 10).

All `game/` paths below are relative to the repo root. Line numbers are from the working tree at the time of writing. `levels_screen.gd` is being edited by someone else, so it is cited by function, not by line.

---

## 1. The references

I looked at all eleven images. Most are 671 x 1440 phone screenshots of one game (Blockfall); 9, 10 and 11 are different games.

### ref/4.png and ref/6.png: Blockfall gameplay

What the image shows: a 10 x 20 board that fills about 71% of the width (cells about 47 px of 671), with a 125 px column on the right for NEXT, TIMER and two buttons. Top row is four equal white rounded tiles (HOLD, SCORE, TIME/LEVEL, PAUSE), about 120 px tall. Bottom row is five square buttons, about 120 px tall, with a thick dark outline.

Take:
- HUD as one row of equal-width cells, with a small label above a big number. Score is the same size as the other tiles there; we make it larger.
- Cells are flat, no bevel, no gradient. Grid is a hairline in a slightly darker tone than the board.
- Ghost is a 1.5 px outline of the cell, no fill. At 71% board width it still reads.
- Muted piece colors: pastels with a lightness range narrow enough that the board looks calm. Colors are still distinct from each other in hue.
- A line of cells stays the same square at every size: the board is the biggest thing on screen.

Reject:
- The right column. It costs about 29% of the width. We need at least 85%.
- HOLD (out of scope) and the duplicated TIME tile (it appears in both the top row and the right column in ref 4).
- Pastel pieces on a near-white board. In ref 4 the yellow and the beige/tan are close and the empty cell is nearly the same lightness as them. Contrast between filled and empty is weak. We need a clearer filled-versus-empty step.
- The tinted salmon HOLD button: a second colored button competing with the controls. We have one accent at most.
- Added: both screens have a small logo above the HUD. It takes 50 px for nothing during play. Drop it from the gameplay screen.
- Added: the drop and rotate buttons sit in different places from the arrows, and ROTATE is bottom-left, far from the right thumb. We place hard drop away from the others on purpose and keep rotate under the right thumb.

### ref/8.png: Blockfall menu

Shows: an isometric cube built from seven tetromino-shaped pieces, about 310 px wide (46% of width), the pixel wordmark BLOCKFALL about 500 px wide (75% of width, cap height about 40 px), then three pill buttons, each 560 px wide x 90 px, in sage, lavender-grey and warm grey. Under them a bracketed "[ Credits & Info ]" link.

Take:
- The hero is made of the game's own pieces, so you can tell what the game is without reading.
- The wordmark is lettering with character: heavy, square, pixel-edged, wide.

Reject:
- Three buttons with the same size and almost the same weight. No primary. (Sage Play is slightly different, but not enough to see at arm's length.)
- Pill shape.
- The isometric 3D render. It is a different style from the flat board and it would not match our flat cells. Our hero will be a flat arrangement of the 7 pieces.
- Faint grid-of-hexagons background drawing. It adds no information.

### ref/3.png: Blockfall pause

Shows: dimmed game behind (about 85% opaque paper color), logo, "PAUSED" at about 70 px bold, then four full-width buttons about 590 x 90 px. The first is solid near-black with white text. The other three are white with a 3 px dark outline. Radius is about 30 px (not a full pill).

Take:
- Exactly this hierarchy: one filled, three outlined. Same width, same height, stacked, 20 px gaps.
- Big title, short word.
- The scrim is a flat tint, not a blur.

Reject:
- The logo on the pause screen. It repeats the title in function.
- The outline weight on the secondary buttons: 3 px at 671 px is heavy next to bold text. We use a thinner outline or a tint.

### ref/5.png and ref/1.png: Blockfall settings (light and dark)

Shows: a column of rounded cards, each with an uppercase section name (LANGUAGE, AUDIO, HAPTICS, CONTROLS, GAMEPLAY), rows with the label on the left and a toggle, slider or chooser on the right. Each card is about 615 px wide and 150 to 350 px tall, with a 2 px border.

Take:
- Plain row labels, controls aligned right.
- Section names in caps; settings are grouped by what they do.
- Toggle is a pill with a dot: the only place a pill belongs.
- The dark version (ref 1) with the same layout shows the structure holds in both directions. The accent (salmon) stays the same in both.

Reject:
- A bordered card per group. Use a section label and extra space.
- The back-arrow button in a box and the logo in the corner: two chrome items to say "settings".
- More settings than we implement (language, music volume, left-handed mode, button size, ghost toggle). MVP1 has sound and haptics.
- Added: in ref 1 the title "SETTINGS" is nearly invisible against the background (grey on light). Title contrast must be checked on every screen in both themes.

### ref/2.png: Blockfall themes

Shows: six named palettes ("Ivory / Coral", "Charcoal / Bone"), each with a 7-swatch preview.

Take:
- A palette is named as a pair, background / ink. That is how we write ours down in `README_VISUAL_DESIGN.md`.
- The seven piece colors are almost the same across all six themes. Only the ground changes. This is a useful constraint for us: choose the 7 piece colors once and make sure they work on both a light and a dark ground.

Reject:
- A theme picker (not in MVP1).
- A white bordered row with a 2 px outline for each option.

### ref/7.png: Blockfall modes

Shows: five translucent tinted cards over a blurred 3D cube. Each has an icon, a title, a description line, and sometimes a "Best: 63705" chip. Cards about 590 x 150.

Take: nothing for layout. One small thing: score shown as "Best: n" in a chip works as a label-plus-number pair, but we do that with a plain label and number.

Reject: the whole screen. Frosted glass, a blur over a 3D render, pastel fills in five different hues with no meaning, subtitles under every title. This is the pattern the brief says to avoid.

### ref/9.png: dark minimal board

Shows: 10 x 15 board, 76 px cells in a 1230 px wide window, so the board takes about 62% of the width, with a narrow right column: score (small, about 30 px), three NEXT pieces drawn as 3 x 3 grids, and a pause icon at the bottom. Empty cells are `#3c3c3c` rounded squares on `#292929`. Gap between cells is about 4 px (5%). Radius is about 12 px (16%).

Take:
- Empty cells as lighter tiles with a gap: the empty board has texture and there are no grid lines to draw.
- Piece colors count: green, yellow, orange, brown, red, blue, teal, purple. Nine hues in a dark scene, none glowing. Brown and the red-orange read as "earth", not "neon".
- Score as a number with no label. No panel.
- The NEXT preview drawn on the same cell grid (3 x 3 tiles, same radius), so the preview matches the board.
- Pause is only an icon.

Reject:
- The narrow right column (same reason as ref 4).
- Brown next to orange next to a red-orange: in grayscale the orange `#e58f3f`, the red-orange and the yellow are close. We have to check this properly (see section 3 on our own palette).
- Fully rounded 16% cells at small sizes: at 33 dp cells the corner is 5 dp, which is fine; at 25 dp on a short screen it turns blobby. Keep the radius a fixed small number.
- The system window chrome and drop shadow (not part of the design; just the screenshot).

### ref/10.png: jewel-block game (anti-reference)

Shows: royal-blue gradient background, a neon cyan frame on the board, beveled gem cells with white highlights, purple sparkle particles above the active piece, a gold coin counter, and a glossy purple pause orb.

Take: one thing only, as a warning: the active piece reads very clearly here because it is the only one with particles, and the ghost cells are drawn as a plain dark outline. The ghost-as-outline approach is right. Nothing else.

Reject: bevel, glow, gradients, particles, coin counter, orb button. Our current `board_view.gd:147` (a 30% lighter 2 px border on each cell) is a mild step toward bevel; that goes.

### ref/11.png: Two Dots

Shows: a light grey top bar with "30" (about 85 px, thin weight) over "MOVES" (about 35 px caps), a menu icon, and target counters: a dot and "0 / 25". Below, a navy field with six columns of flat circles in six colors. Nothing else on the screen. Large pale shapes (a letter form) sit behind the dots as a watermark. The bottom has a bar with three dots.

Take:
- Big number, small label, nothing between them. 30 over MOVES has a 2.4 : 1 size ratio. We use a similar ratio for score over its label.
- Flat color with no outline, no highlight, no shadow. 6 colors on one ground.
- A lot of empty space between HUD and play area; elements are not boxed.
- The top bar is a solid, flat band with a rounded outer corner, not a bordered card.
- The unit is large: dots are 76 px of 1500 (5%) with 150 px spacing; the board does not shrink to make room for chrome.

Reject:
- Circles (our unit is the square cell).
- Wavy decorative bands.
- The thin weight of the "30": a thin numeral jitters when it changes and is hard to read at arm's length in motion. Use a bold weight with tabular figures.

### What MasterPrompt section 3 missed

1. Blockfall's board is 71% and ref 9 is 62%. No reference reaches 85%. Our 85% target is stricter than all of them, so no reference can be copied for layout of the HUD; we have to design that row from scratch.
2. Weak filled-versus-empty contrast in ref 4 and 6 (pastel on near-white). The reference that gets this right is ref 9 (dark empty cell, saturated filled cell). Whatever we choose, filled cells need at least about 3:1 contrast with empty cells.
3. Title contrast failure on ref 1 (back-arrow and "SETTINGS").
4. Control-bar order in ref 4 and 6: rotate is far left, but it is the most-used button after left/right. Not to copy.
5. Every Blockfall screen carries a logo. Games do not need one on every screen.

---

## 2. Slop signals confirmed against the code

All eight signals in MasterPrompt section 2 are present. Evidence:

| # | Signal | Evidence |
|---|---|---|
| 1 | It is a web page | `game/scripts/game_theme.gd:9` `UI_SCALE := 1.5` ("CSS px"); header comments cite prototype CSS classes throughout (`:53`, `:107-108`, `:191`, `:201`, `:255`). Eyebrow label type at `:54`. Card, pill, avatar, segmented control types: `StatCard :202`, `StrongCard :206`, `PausePanel :210`, `SegmentedBox :214`, `AvatarCircle :228`, `LevelPill :240`, `SegmentButton :149`. |
| 2 | Two-tone accent headlines | Types: `DisplayAccent` (`game_theme.gd:70`), `HeadingAccent` (`:74`). Used: `main_menu.tscn:105-111` "Find your / flow."; `leaderboard.tscn:102-107` "Who's / on top?"; `sign_in.tscn:94-101` "Welcome / back."; `game_over_overlay.tscn:64-73` "Nice run. / One more?"; levels scene `levels.tscn:96-102` "Climb one level / every 10 lines."; also set from code: `sign_in_screen.gd:34-35` ("Save your / progress."), `game_over_overlay.gd:25-26` ("Beautiful. / A new best."). The wordmark is also two-tone: `Brand` + `BrandAccent` (`game_theme.gd:62-64`, `game.tscn:80-88` "DROP" / "GRID"). |
| 3 | Tagline copy | `main_menu.tscn:116` "Stack smart. Clear lines.\nBeat your best."; `main_menu.tscn:101` "A FOCUSED ARCADE PUZZLE"; `pause_overlay.tscn:82` "Take a breath.", `:88` "Your board is waiting for you."; `game_over_overlay.tscn:59` "Run over", `:66` "Nice run.", `:73` "One more?"; `sign_in.tscn:108` "Sync your best score, lines, and games across devices. Guest play always stays free.", `:220`; `leaderboard.tscn:175`; `leaderboard_screen.gd:38` "Be the first on the board." and `:48` "Couldn't reach the leaderboard\nCheck your connection..."; `settings_overlay.tscn:152` "Movement, clears, and feedback", `:233`. |
| 4 | Default dark-dashboard palette | `game/scripts/palette.gd:6` `BACKGROUND #0B1020` (blue-black), `:16` `ACCENT #7C9CFF` (periwinkle), `:22` `SUCCESS #62E6B5` (mint). `project.godot:34` clear color is the same blue-black. 23 color tokens; for comparison the brief allows 2 + 1 + 2 + 1 + 1 + 7 = 14. Tokens that exist for decoration: `ACCENT_SOFT :17`, `ACCENT_BORDER :19`, `ACCENT_ROW_BORDER :20`, `DANGER_SOFT :25`, `DANGER_LINE :26`, `SURFACE_3 :10`, `LINE_STRONG :12`, `TEXT_FAINT :15`, `WARNING :23`, `BACKGROUND_DEEP :7`. |
| 5 | No typographic identity | `game_theme.gd:36-48`: `SystemFont` with names `["Helvetica Neue", "Segoe UI", "Roboto", "Arial"]`. On Android that resolves to the system font, so the look changes per device. Bold is `variation_embolden = 0.9` (`:47`), a smeared fake bold. `assets/` holds `audio` and `icons` only; there is no font file. Score is a normal `Label` (`hud_controller.gd:30`, type `Value` at `game_theme.gd:76`), proportional digits, so "1" and "8" have different widths and the number moves as it changes. Sizes in use: 14, 15, 16, 18, 19, 20, 21, 24, 25, 27, 33, 45, 48, 66, plus inline 30 and 16 (`game.tscn:81,87,308,343,379,414,451`). That is 14 sizes against a limit of 5. |
| 6 | Card soup | `StatCard` wraps the whole HUD in one panel (`game.tscn:116`) and the profile stats in four (`profile.tscn:154,174,194,214`), each with a 2 px border (`game_theme.gd:203`). Game over: `StrongCard` (`game_over_overlay.tscn:78`) holds three stat blocks. Pause: `PausePanel` (`pause_overlay.tscn:48`) holds `IconTile` (`:60`). Settings: each row is a `CardButton` (`settings_overlay.tscn:96,177`) holding a `SettingIcon` tile (`:124,205`), a title, a muted subtitle and a toggle. Profile: delete dialog is a `StrongCard` (`profile.tscn:301`) inside the screen. Leaderboard rows are `LeaderRow` cards with a 2 px border (`game_theme.gd:222-225`). |
| 7 | Decorative icons | `assets/icons/sparkles.svg` is used on the main menu next to "Levels" (`main_menu.tscn:10,252`). A four-point star means nothing in a block game. `trophy.svg` (`main_menu.tscn:219`) is a generic leaderboard icon. `wifi_off.svg` is not referenced from any scene or script. The set mixes styles: `pause.svg` is a filled shape (`<path ... fill="#FFFFFF">`) while `sparkles.svg` and the others are 2 px stroke with round caps on a 24 grid. Every icon is exported at 96 px from a 24 viewBox. |
| 8 | Fake progression decoration | `levels.tscn:76,92` "Level path"; the screen builds 12 nodes (`NODE_COUNT := 12` in `levels_screen.gd`), each with a completed, current or locked state, and an accent-bordered "current" card. This is the saga-map pattern. MVP1 replaces it with a 10-item picker. |

### Further generic patterns found

1. **Colors set in scenes and scripts, against the brief's own rule.** `game.tscn:148,176,205` (divider `ColorRect`s, `Color(0.1608, 0.2118, 0.3255)`), `game.tscn:272,443` (`self_modulate`), `main_menu.tscn:144,218,251`, `pause_overlay.tscn:118`, `game_over_overlay.tscn:172`, `leaderboard.tscn:147` (icon `modulate`). In scripts: `leaderboard_screen.gd:26,49,65,68`, `game_over_overlay.gd:28`, `levels_screen.gd` (`_style_current`, builds a `StyleBoxFlat` with `Palette.ACCENT_SOFT`). These pass through `Palette`, but they are style decisions living outside `GameTheme`. Hard-coded `Color(...)` in the scenes bypasses `Palette` altogether.
2. **Pill shape used for more than toggles.** `RADIUS_PILL := 200` (`game_theme.gd:16`) is used by `AvatarCircle`, the four toggle parts (`:244-252`). `LevelPill` (`:240`, radius 12 on a short label) reads as a pill. Seven radii in use: 4, 12, 16 (board panel, `board_view.gd:78`), 18, 20, 24, 36, 200.
3. **Rainbow control bar.** `PadRotate` is accent blue (`game_theme.gd:145`), `PadHard` is amber (`:147`), `PadPause` is soft accent (`:143`), others are surface. Four button colors on a six-button row, each button also carrying a text label ("Left", "Right", "Soft Drop"... at `game.tscn:310,345,416,453`) under the icon, so it is both icon and word.
4. **Pause is in the control bar** (`game.tscn:252-257`), the position where the thumb is most active, next to Left. A mis-tap pauses the game. It is 72 x 110 px.
5. **Brand header on the gameplay screen.** `game.tscn:55-88` and `:99-105`: a mark, "DROP" + "GRID", and a "Level 01" pill, in a 54 px row. This is a web page header. Level is then shown a second time in the HUD ("LEVEL" appears in the game over scene and profile; on game.tscn the HUD shows LINES, SCORE, NEXT, DROP).
6. **Developer-facing stat.** The HUD shows "DROP 0.80s" (`game.tscn:219-226`, `hud_controller.gd:41`). A player does not think in seconds per step; this is a debug value presented as a stat. The level number would carry the same meaning.
7. **Score is not the dominant element.** The HUD has four equal-width columns (`game.tscn:116-226`): LINES, SCORE, NEXT, DROP. SCORE has the same type size (27) as the others. The brief wants the score to be the largest number on screen.
8. **Dividers and cards in the HUD**: three 2 px `ColorRect` dividers (`game.tscn:144,172,201`), inside a bordered `StatCard`.
9. **Tooltips on a phone UI**: "Go back", "Pause game", "Move left" etc. (`*.tscn` `tooltip_text`) do nothing on touch.
10. **Zero-padded level label** "Level 01" (`hud_controller.gd:39`, `levels_screen.gd`: `"%02d"`). Reads as a counter on a dashboard.
11. **"Continue as guest" as a ghost button** on the main menu (`main_menu.tscn:194`): presents guest play as the lesser path, which the brief says not to do. The main menu also has Sign in / Levels / Leaderboard / Settings in a mix of secondary and ghost styles (`:159-260`) with no set order.
12. **Placeholders as copy**: "you@example.com", "At least 8 characters", "3 to 20 characters" (`sign_in.tscn:154,170,188`). Acceptable on a form, but the title block above the form is the problem, not these.
13. **Version line on the menu**: "DropGrid · v1.0.0" (`main_menu.tscn:284`). Belongs in settings.
14. **Cell drawing has bevel traces.** `board_view.gd:147` lightens each cell border by 30% at 2 px (a top-lit look), `:115` adds a white flash overlay at 60% alpha on lock, `:120` the ghost is a 22% alpha fill rather than an outline (the brief wants an outline, and ref 4, 6 and 10 all use one). `_draw_empty_cells` (`:83`) and `_draw_grid` (`:92`) both draw: tiles with gaps and hairlines on top of them. Pick one.
15. **Piece colors collapse in grayscale.** Luma (0.299 R + 0.587 G + 0.114 B, 0 to 255) of `Palette.PIECE_COLORS` (`palette.gd:37-43`): I 181, O 209, T 165, S 175, Z 174, J 139, L 187. Six of seven lie between 165 and 209, and S, Z and I are within 7 of each other. By lightness alone they cannot be told apart; the set relies on hue, which fails for the roughly 1 in 12 men who are red-green deficient (green S against pink Z, orange L against green S). Section 8's grayscale test would fail today.
16. **No animation at all.** `grep` for `create_tween` / `Tween` in `game/scripts` finds nothing. The only motion is a 0.12 s white flash on lock (`board_view.gd:9`). Buttons switch state with a 12% lighten (`game_theme.gd:176`). This is not slop; it is an unfinished game feel, and Phase 4 has to add every item in the motion list.

---

## 3. Current gameplay layout, measured

Source: `game/scenes/game.tscn`, `game/scripts/board_view.gd`, `game/project.godot`. Base viewport 720 x 1280, stretch `canvas_items`, aspect `expand`.

Structure, top to bottom, inside a `MarginContainer` with 12 px left and right and 16 px top and bottom (`game.tscn:45-48`):

| Part | Height (design px) | Source |
|---|---|---|
| Top margin | 16 | `:46` |
| Header (mark, wordmark, level pill) | 54 | `:56` |
| Gap | 12 | `:107` |
| HUD card (StatCard, 15 px padding, content set by the NEXT preview at 52 px plus caption and gap) | about 106 (estimate: 30 + 20 + 4 + 52) | `:112-195`, `game_theme.gd:203` |
| Gap | 12 | `:232` |
| Board area | whatever remains | `:228-238` |
| Gap | 12 | `:243` |
| Control bar | 110 | `:247` |
| Bottom margin | 16 | `:48` |

Board cell size: `board_view.gd:39-40`, `minf(size.x / 10, size.y / 20)`. The board is centered in the control (`:58`).

**At the base 720 x 1280:** board area height = 1280 - 16 - 54 - 12 - 106 - 12 - 12 - 110 - 16 = 942. Cell = min(696 / 10, 942 / 20) = min(69.6, 47.1) = **47.1 px**. Grid width **471 px = 65% of 720**. The board panel itself is drawn at the full 696 px (`board_view.gd:60-62`), so the area beside the grid is painted as board but holds nothing: about 112 px of dead panel on each side.

**At 390 x 844 (the project's window override, `project.godot:22-23`):** `expand` keeps the width 720 and stretches the height to 720 x 844 / 390 = 1558. Board area = 1220, cell = min(69.6, 61.0) = **61.0 px**, grid **610 px = 84.7% of 720**. This is close but under 85%, and the gap comes from chrome (header, HUD card and 12 px gaps) taking 338 of 1558 px.

**At 360 x 640** (short): viewport 720 x 1280, same as the base case: **65%**. **At 412 x 915**: viewport 720 x 1284 * ... about 1283 tall, nearly the same as base, so about **65%**.

Control bar: 110 design px, which at 390 wide is 59 dp. Pause button 72 x 110 design px (39 x 59 dp); the others share the rest. Touch targets pass 48 dp on height; the pause button is 39 dp wide and fails on width.

HUD height: 106 px estimated (57 dp at 390). Header: 54 px (29 dp).

**Verdict:** does not meet "board at least 85% of width". It gets 65% on the base viewport and on short and typical-tall phones, and 84.7% only at exactly 390 x 844. The numbers for the HUD are estimates from the scene's minimum sizes; Phase 2 screenshots will confirm. The cause is vertical: chrome plus HUD plus controls take about 27% of the height, so the height limits the cell before the width does.

**A consequence for the design brief.** 10 x 20 is a 1 : 2 board. To get 85% of 390 (332 dp) the board must be 664 dp tall. 844 - 664 = 180 dp for everything else, including the status bar inset and the gesture-bar inset (about 24 + 16 on a typical phone). That leaves about 140 dp for the HUD, the control bar and the gaps. It fits only if the header goes away, the HUD is one slim row (about 44 dp) and the control bar is about 80 dp. On a 360 x 640 phone the 85% target cannot be met at all: 640 - 40 insets - 124 chrome = 476 dp, cell 23.8, board 238 dp = 66%. See open question 1.

---

## 4. Three concepts

All three keep the architecture (`Palette`, `GameTheme`, views as pure drawing). All three fit light or dark, and I give a direction for each so Phase 2 can build both. Piece colors in all three must pass the grayscale test: at least three distinct lightness steps among the seven, with no two within about 12 luma points unless they also differ by a mark.

### Concept A: Printed Puzzle

**One sentence:** The game is a printed puzzle book: matte paper, one ink color, and pieces in flat pigment colors with no shadow.

**What it decides**
- Palette direction: light is the home direction. Paper `#EFE9DD`-ish warm off-white, ink near-black with a warm tint, one accent in a terracotta or tomato red, danger the same red family but darker. Dark version: the "Charcoal / Bone" inversion (ref 2), charcoal ground with bone ink. Piece colors are muted print pigments (mustard, brick, teal, olive, plum, slate blue, tan), chosen with at least three lightness levels.
- Type candidates:
  - IBM Plex Sans (regular and bold) with IBM Plex Mono for numerals. SIL OFL 1.1. Mono figures are tabular by construction.
  - Chivo (regular, bold) with Chivo Mono. SIL OFL 1.1.
  - Space Mono as a single-family option. SIL OFL 1.1. Has a quirky character that suits a puzzle book.
  - Score in the mono face at the largest size; labels in caps at the smallest size.
- Cell rendering:
  - Empty: paper tile one step darker than the ground, 1 unit gap, no grid lines.
  - Filled: flat pigment, no border, no highlight.
  - Ghost: 2 px ink outline, no fill.
  - Active: the same flat pigment plus a 2 px ink outline, so it differs from locked cells without any glow.
  - Clearing: the row fills solid ink for 80 ms, then the cells are removed in one step (no particles).
- Button shapes: rectangles with a 4 px radius (the same as the cell radius). Primary is filled ink with paper text. Secondary has a 2 px ink outline. Text button is underlined ink. As in ref 3.
- Motion character: "stamps": things arrive in one frame and settle in 60 to 120 ms; nothing slides or springs. Lock is a 1-frame darken. Overlay in is a fade of 120 ms.

**Draws on:** ref 3 (button hierarchy), ref 2 (named palette), ref 9 (empty tiles, earthy pieces), ref 4 (flat cells, outline ghost), ref 11 (big number over a small label).

**Main risk of turning generic:** warm beige plus terracotta plus a serif or mono is now the standard "calm productivity app" look (the same ground as the ref 4 screenshot). Without a strong wordmark and hero it will look like a journaling app with a Tetris inside it.

### Concept B: Cell Unit

**One sentence:** The grid is the brand: every element, including the wordmark, the icons, the buttons and the hero, is built from the board's square cell, in whole multiples of it.

**What it decides**
- Palette direction: a two-ground pair that works in both modes, with one accent. Dark: warm graphite ground (not blue-black), off-white ink, accent a single signal color (a hot orange-red or a yellow-green; decided in Phase 2). Light: off-white ground, graphite ink. Pieces: seven flat colors of mid saturation, with a wide lightness spread (some dark, some light), so the board is legible in grayscale.
- Type candidates:
  - Departure Mono for the wordmark and the score. SIL OFL 1.1. A pixel-grid face that sits on the cell unit; tabular because monospaced.
  - Martian Mono for labels and buttons. SIL OFL 1.1. Has several widths and weights in one family.
  - Space Mono or JetBrains Mono (OFL 1.1) as a fallback body face.
  - Silkscreen (OFL 1.1) as a wordmark-only option.
  - One mono family, two weights, plus the pixel face only for the wordmark and the score.
- Cell rendering:
  - Empty: a tile in a slightly lighter or darker ground, 1/8 cell gap (as in ref 9), radius 0 or 1/8 cell. No grid lines.
  - Filled: flat color with a 1/8 cell "inset frame": a ring one tone darker, then the fill. A hollow-frame block in the style of early handhelds, no gradient and no highlight.
  - Ghost: only the 1/8 cell frame, no fill.
  - Active: filled, with the frame in the ink color so it reads as "live" without a glow.
  - Clearing: the row's cells turn to the ink color and shrink to their frames, then the row collapses. 120 ms.
- Button shapes: rectangles whose height is a whole number of cells (a 2-cell or 2.5-cell high button; 2 cells at 33 dp is 66 dp, which clears the 48 dp target). Radius 0 or 2 dp. Primary: filled accent. Secondary: 2 px outline. Text: none. Gamepad buttons are square multiples of the cell.
- Motion character: "steps": all motion is quantized to the cell unit (a piece moves one cell, never between). Score changes tick with no easing. Overlays enter in one step of 100 ms.
- Hero: the seven pieces laid out as a 10-wide arrangement, flat, with the wordmark as the top row in the same cell style.

**Draws on:** ref 8 (hero from the pieces, pixel wordmark), ref 9 (empty tiles, earthy colors, number-only score), ref 4 (flat cells, ghost outline), ref 3 (button hierarchy), ref 11 (big flat shapes carry the brand).

**Main risk of turning generic:** a pixel font plus hollow blocks reads as "retro Tetris pastiche", the most common indie block-game look, and the default free pixel fonts are widely used. It needs a custom wordmark (drawn, not typed) and discipline about not adding scanlines, CRT effects or neon.

### Concept C: Color Field

**One sentence:** The screen is a few large flat rectangles of color, with the board as one field and the numbers set big and plain on top of it, in the way of Two Dots and Bauhaus posters.

**What it decides**
- Palette direction: a saturated ground, not neutral. Candidates: deep ultramarine or deep green ground with a pale paper HUD band (as in ref 11: pale band, deep field), or an off-white ground with a deep field behind the board. One accent used only for the primary button. The 7 piece colors are primaries and secondaries (red, yellow, blue, green, orange, purple, teal) kept flat and moderately light so they sit on the deep field; the grayscale test is the main constraint.
- Type candidates:
  - Space Grotesk (SIL OFL 1.1; tabular figures via the `tnum` feature) for UI and score.
  - Archivo (OFL 1.1, has a wide width axis) for the wordmark in a wide heavy cut.
  - DM Mono (OFL 1.1) for small labels.
  - Check `tnum` support when bundling; Godot 4 supports OpenType features in `FontVariation`.
- Cell rendering:
  - Empty: no tiles; the board is one solid field a half step lighter than the ground, so the empty board is a clean rectangle.
  - Filled: flat square, 0 radius, 1 px gap in the field color (so the pieces form shapes, as in ref 11 where large forms carry the look).
  - Ghost: a 2 px outline in the piece color at full strength.
  - Active: filled, with the same fill but a notch lighter (about 10%) than a locked cell. No outline.
  - Clearing: the row flashes to white for 60 ms and the field closes over it.
- Button shapes: full-width solid bars, 0 radius, flush to the screen edge at the bottom of overlays (like the ref 11 bottom bar). One bar color for primary, the field color with an outline for the others.
- Motion character: "slides": panels and bars enter by translating 24 dp over 160 ms with ease-out; pieces do not animate between cells.
- Hero: the seven pieces as large flat color blocks cropped by the screen edge (ref 11's background letters).

**Draws on:** ref 11 (flat color, big number over small label, large shapes as brand, generous space), ref 4 and 6 (HUD as one band, ghost outline), ref 3 (single primary), ref 8 (hero from pieces).

**Main risk of turning generic:** saturated flat color with rounded corners is also the look of every casual puzzle game on the store. The board has to stay square, tight and un-rounded, or it becomes Candy Crush with square candies. It also depends on the 7 colors being picked carefully; the "primary" palette can drift into kindergarten.

---

## 5. Recommendation: Concept B, Cell Unit

Reasons tied to this game:

1. **The 85% width target is a layout problem, and B turns it into a rule.** At 390 x 844 the cell is about 33 dp. If every control height, every gap and every type size is a multiple of that cell (or of 1/8 of it), there are only a few sizes to choose, and the HUD row (about 1.5 cells high) and the control bar (2.5 cells high) are decided by the same number as the board. This is the only concept where the board is the ruler for the rest of the UI.
2. **Thumbs at the bottom.** Cell multiples give predictable touch targets: a 2-cell button is 66 dp, well over 48 dp. Left, right and rotate are 2 cells wide each and sit under the thumbs; hard drop is 2 cells wide too but separated from the rest by a gap of a full cell, so it is hard to hit by accident.
3. **The 7 pieces are the brand.** The game has exactly seven shapes on a 10 x 20 grid; the wordmark, hero and level picker can all be drawn from those pieces with no extra assets. Icons (pause, rotate, arrows, hard drop) are drawn on the same grid in 1-cell strokes, which solves the "one stroke width, one grid" requirement.
4. **It carries over to both light and dark.** The identity is in the shape of the unit, not the ground, so Phase 2 can try both grounds without redoing the concept. A depends on a warm light ground to work. C depends on a saturated ground.
5. **Tabular figures come for free.** The score face is monospaced, so digits do not shift. The other concepts need to verify `tnum` support.
6. **The risk is the least harmful.** "Retro pastiche" is avoided by drawing the wordmark and by not copying console effects. A's risk (beige journaling look) and C's (casual-puzzle look) both damage the board's readability or the brand, and a bad pixel font is easy to swap.

Honest weakness: Departure Mono and Martian Mono are both known faces. If the wordmark is just typed in one of them, this concept fails the "cover the logo" test. The wordmark must be drawn on the cell grid.

---

## 6. Gameplay wireframe, recommended concept

Canvas: 390 x 844 dp. The drawing is not to vertical scale (1 text row is about 16 dp; 1 character is about 6.5 dp wide). Cell = 33.2 dp.

```
 x: 0                                                    390
    +--------------------------------------------------------+  y=0
    |  status bar inset                                  24   |
    +--------------------------------------------------------+
    |                                                        |
    |  SCORE           LEVEL    LINES     NEXT         ||    |  HUD, 44 dp
    |  12,480           04       37       [piece]     pause  |  score = largest
    |                                                        |  type on screen
    +--------------------------------------------------------+  y=68 (+8 gap)
    |   +------------------------------------------------+   |
    |   |. . . . . . . . . . . . . . . . . . . . . . . .|   |
    |   |                                                |   |
    |   |            [##][##]                            |   |
    |   |                 [##][##]   <- active piece     |   |
    |   |                                                |   |
    |   |            [  ][  ]       <- ghost (frame only)|   |  board
    |   |                 [  ][  ]                       |   |  332 x 664
    |   |                                                |   |  10 x 20 cells
    |   |  [##]                                          |   |  of 33.2
    |   |  [##][##]            [##]                      |   |
    |   |  [##][##][##]  [##]  [##][##]                  |   |
    |   |  [##][##][##][##][##][##][##][##]  [##]        |   |
    |   +------------------------------------------------+   |
    |   29 dp margin each side: board = 332 / 390 = 85.1%    |
    +--------------------------------------------------------+  y=744 (+8 gap)
    |                                                        |
    |   [ < ]  [ > ]    [ rot ]  [ down ]        [ DROP ]    |  controls, 80 dp
    |                                                        |  (gap before DROP)
    +--------------------------------------------------------+
    |  gesture inset                                     16   |
    +--------------------------------------------------------+  y=844
```

Numbers:
- Board width: 332 dp of 390 = **85.1%**. Margins 29 dp each side.
- Vertical budget: 24 (top inset) + 44 (HUD) + 8 + 664 (board) + 8 + 80 (controls) + 16 (bottom inset) = 844. There is no slack. Real insets vary by phone, so Phase 2 must read the safe area from `DisplayServer.get_display_safe_area()` and the layout has to hold at 85% with a 24 and 16 inset only. With larger insets the cell shrinks and the board drops below 85%.
- HUD: one row, no card, no dividers. Score is 2x the size of the other three values. Labels are a size smaller, in caps. The next piece is drawn with the same cell style at about 0.5 cell. Pause is an icon at the right of the HUD, away from the movement buttons (it was in the control bar before).
- Controls: left and right on the left, rotate and soft drop in the middle-right, hard drop alone on the far right with a one-cell gap before it. Each button is at least 66 x 80 dp. The labels under the icons ("Left", "Soft Drop"...) go; icons only.
- No header, no wordmark, no level pill on the gameplay screen. Level lives in the HUD.

---

## 7. Open questions for the user

1. **The 85% rule on short phones.** At 390 x 844 the target is reachable only with a very tight vertical budget (the table in section 6 has no slack). At 360 x 640 it cannot be met: the board gets about 66% of the width, because the board is 1 : 2 and the height runs out first. Do you want (a) a hard 85% only on typical and tall phones and the best possible fit on short ones, or (b) a different rule, such as "the board is at least 85% of the height left after the HUD and controls"?
2. **Where does the next piece live?** In the HUD row (as drawn, small), or beside the board at some cost in width? The brief implies the HUD row.
3. **Pause position.** I propose moving it from the control bar to the HUD, top right. It is then a smaller target far from the thumbs, which is the point (fewer accidental pauses), but it costs a longer reach to pause on purpose. Confirm.
4. **Hard drop placement.** Far right, alone, with a one-cell gap: right-handed bias. Do you want a left-handed swap setting? That would be a new setting beyond sound and haptics, so it is out of MVP1 unless you say so.
5. **Level display in the HUD.** Is "level" worth a HUD slot when the player starts at a chosen level and it rises every 10 lines? And should the "DROP 0.80s" stat go entirely? I propose yes to the first, and yes to removing the second.
6. **Start-level picker.** Ten items in a grid (2 x 5 or 5 x 2 of cell-sized tiles) with the number only and locked ones dimmed, or a list with the fall speed? I propose a grid with the number only; the speed is a detail that does not help the choice at the first glance. Unlock rule text ("needs 40 lines") is shown only for the locked tile that was tapped. Confirm.
7. **Wordmark.** DropGrid as one word in one color. Are you open to commissioning or drawing a custom wordmark rather than typing it in a font? Concept B needs a drawn one.
8. **Accent color.** Do you have a color you want to avoid or keep? The current periwinkle goes in every concept.
9. **Guest and sign-in on the main menu.** I propose Play (primary), best score, and then a quiet row of three text entries: Leaderboard, Settings, Account. "Continue as guest" is deleted because guest is the default. Confirm.
10. **Font licence record.** Fonts are OFL 1.1. I propose `game/assets/fonts/OFL.txt` plus a line in `README_VISUAL_DESIGN.md`. Is there any other place the Play listing needs it?

---

The process stops here for the user to pick a concept.
