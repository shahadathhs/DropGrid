# Visual Design

The look is called **Cell Unit**: the board's square cell is the unit for everything. The board, the next-piece preview, the wordmark and the level tiles all draw blocks through one helper (`game/scripts/cell_style.gd`). The tokens live in `game/scripts/palette.gd` and the styles in `game/scripts/game_theme.gd`; this file describes the rules those two follow.

## Rules

- One flat ground color. No cards, no gradients, no glow, no glass, no particles, no grid lines.
- Group with spacing and a small caption, not with borders or boxes.
- Corners are 4 px (design units) on every button and field. Toggles are square.
- Exactly one primary button per screen. Primary is filled ink. Secondary is a flat tile. Text buttons are quiet.
- Copy is short labels. No taglines, no questions, no exclamation marks, no two-color headlines, no tooltips.
- Numbers use the pixel face. Text uses the mono face. Both are monospaced, so digits never change width.

## Color

Two grounds share one design. Dark is the default; pass `--light` after `--` on the command line to preview light.

| Token | Dark | Light |
|---|---|---|
| Ground | `#161513` | `#EFEBE2` |
| Empty tile | `#262320` | `#E3DED2` |
| Text / ink (also the primary fill) | `#ECE7DC` | `#1B1A17` |
| Muted text | `#A09A8E` | `#6B665C` |
| Signal (hard drop, delete, errors) | `#FF5A36` | `#D63A18` |

Pieces use seven hues with brightness about 23 points apart, so they can still be told apart in grayscale (by brightness on dark: J, T, Z, S, L, I, O):

| I | O | T | S | Z | J | L |
|---|---|---|---|---|---|---|
| `#96DCE6` | `#F6E292` | `#874CCB` | `#58C083` | `#DB548C` | `#265AB4` | `#F59F5D` |

Light-ground piece colors are in `palette.gd`.

## Type

- **Martian Mono** (variable weight, SIL OFL 1.1) for text, buttons and captions.
- **Departure Mono** (SIL OFL 1.1) for the score, level and line numbers, and screen titles.
- Licenses sit next to the fonts in `game/assets/fonts/`.

## Blocks

- A tile sits in its cell with a gap of 1/8 cell.
- A locked block is a flat fill inside a darker frame 1/8 cell wide.
- The active piece has an ink frame. The ghost is a frame with no fill.
- The wordmark is drawn from the same blocks (`game/scripts/wordmark.gd`), one piece color per letter.

## Gameplay layout (portrait, 720 design units wide)

HUD in one row: score (largest type on screen), level, lines, next piece, pause. Board below at 85% of the screen width where the height allows it, then one row of controls: left, right, rotate, soft drop, and hard drop separated from the rest by a gap. Icons only, no labels. Pause is in the HUD, away from the thumbs. Safe-area insets are applied on phones.

On short phones (about 360 x 640) the board gets about 66% of the width because height runs out first.

## Previewing without a phone

Debug builds on a desktop can save screenshots, see `game/autoload/device_preview.gd`:

```sh
godot --path game res://scenes/game.tscn -- --shot=/tmp/a.png --size=390x844 --demo
```

`--demo` fills the board, `--overlay=pause|gameover` opens an overlay, `--light` uses the light ground. F9 cycles phone sizes in a running window.

## Status

Built and screenshot-checked: gameplay, pause, game over, main menu, start-level picker, leaderboard, sign in, profile, settings. Not done: motion (line-clear and level-up animations), device testing, a drawn app icon.
