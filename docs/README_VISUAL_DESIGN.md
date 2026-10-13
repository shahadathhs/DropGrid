# Visual Design — Theme, Color, UI, and Layout

## 1. Art direction

Use a **modern, minimalist arcade** style: dark, calm, crisp, and slightly premium. The board should be the visual focus. Use color to distinguish pieces, not to decorate every empty area.

Avoid generic AI-generated dashboard styling, excessive gradients, glassmorphism, noisy backgrounds, and too many rounded cards. The game should feel designed specifically for a falling-block puzzle.

## 2. Color system

Use these as starting tokens. Centralize them in a theme/resource or a small constants file so they can be changed globally.

- **Background:** `#0B1020` — deep blue-black.
- **Primary surface:** `#121A2B` — menus and panels.
- **Secondary surface:** `#1B263B` — secondary controls and highlighted panels.
- **Board background:** `#0A0F1A`.
- **Grid lines:** `#202B40` — subtle, low contrast.
- **Primary text:** `#F3F6FC`.
- **Secondary text:** `#9AA8BE`.
- **Primary accent:** `#7C9CFF`.
- **Success / line-clear accent:** `#62E6B5`.
- **Warning / pause accent:** `#FFC96B`.
- **Danger / game-over accent:** `#FF7185`.

Piece colors should be bright enough to read against the board but not painfully saturated. Suggested palette:
- Cyan: `#55DDE0`
- Blue: `#6688FF`
- Orange: `#FFAA5C`
- Yellow: `#F6D365`
- Green: `#69D69B`
- Purple: `#B38CFF`
- Pink: `#FF83B8`

Check contrast on an actual phone. Do not communicate important state through color alone; combine color with position, animation, or text where useful.

## 3. Typography

- Use a clean sans-serif font with strong legibility at small sizes.
- Prefer one font family with two or three weights.
- Score digits should use tabular/monospaced numerals if the chosen font supports them.
- Avoid tiny labels and long all-caps text.
- Establish a clear hierarchy: screen title, score, secondary stats, control labels.

If a custom font is not included, use a reliable bundled/system fallback. Verify font licensing before shipping any third-party font.

## 4. Portrait layout

Design the game screen from top to bottom:

1. **Top bar:** pause button on the left; compact score/best-score information or a clear score area.
2. **Main board:** centered and visually dominant. Preserve the board's intended cell proportions; do not stretch cells to fill arbitrary space.
3. **Secondary stats:** cleared lines and level, placed where they are visible without shrinking the board too much.
4. **Controls:** large, well-spaced touch buttons near the bottom: left, rotate, right, soft drop. A hard-drop action may be included if it can be made easy to distinguish and difficult to trigger accidentally.
5. **Safe area:** respect device cutouts, rounded corners, and system navigation areas.

Use `Control` containers and anchors appropriately instead of hardcoding every element to one resolution. Check short/tall screens and different aspect ratios.

## 5. Main menu

Keep it simple:
- Game title / logo treatment.
- One obvious primary **Play** button.
- Best score.
- Settings button for sound and other supported options.
- Small, unobtrusive version number only if useful.

Avoid adding a tutorial carousel, shop, profile, or several secondary modes to the first version.

## 6. Game-over and pause screens

**Pause overlay**
- Dim the gameplay behind the overlay.
- Show Resume and Restart.
- Keep the board state intact while paused.

**Game-over overlay**
- Show “Game Over”, final score, and best score.
- Primary action: Play Again.
- Secondary action: Main Menu.
- Make the best-score improvement clear without a large disruptive animation.

## 7. Motion and feedback

Use short, purposeful effects:
- Subtle landing/lock feedback.
- A quick line-clear animation.
- Small score feedback when lines clear.
- Gentle button press states.
- A restrained game-over transition.

Keep animations brief and never let decorative effects block input. Add reduced-motion or simplified-effects settings only if feasible; at minimum, do not rely on intense flashing.

## 8. Sound

Use short, original or properly licensed sounds for movement, rotation, landing, line clearing, and game over. Include a mute toggle. Do not use copyrighted sounds ripped from existing games.

## 9. Design acceptance checklist

- The board is the strongest visual element during play.
- Controls are easy to hit with thumbs.
- Text is readable on a phone at normal viewing distance.
- Empty cells remain visually distinct from occupied cells.
- Every screen has one clear primary action.
- UI adapts to different screen sizes without overlapping.
- No decorative element makes gameplay harder to read.
