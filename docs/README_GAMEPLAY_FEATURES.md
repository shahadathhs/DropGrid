# Gameplay and Feature Specification

## 1. Core loop

1. Start a new game.
2. A piece appears at the top of the board.
3. The player moves and rotates it while it falls.
4. The piece locks when it can no longer move downward.
5. Any completed horizontal lines are cleared.
6. Score, line count, and level update.
7. The next piece spawns.
8. The game ends when a new piece cannot spawn in a valid position.

The loop should be predictable and fair. Avoid introducing extra mechanics unless the basic loop is already reliable.

## 2. Board and pieces

- Use a rectangular grid represented as logical cells, not a collection of unrelated physics bodies.
- Choose a conventional, fixed board width and height appropriate for a falling-block puzzle.
- Define each piece as a set of local cell coordinates plus its color/type.
- Keep the logical board separate from the visual rendering.
- Pieces must not overlap occupied cells or leave the board.
- Rotation must handle wall/floor collisions safely. Basic rotation is sufficient for version 1; implement wall kicks only if needed for a reliable feel.
- A landing/ghost preview is optional, but useful if it can be implemented clearly.
- Use a predictable piece-generation approach. A shuffled bag system is preferable to long streaks of the same piece.

## 3. Controls

### Touch controls
- Left: move one cell left.
- Right: move one cell right.
- Rotate: rotate the active piece.
- Soft drop: increase downward speed while held, or move down one step per press.
- Hard drop: optional; if included, make the control visually distinct from soft drop.

### Input behavior
- Controls must respond promptly.
- Holding left/right may repeat movement after a short initial delay.
- Buttons should have clear pressed states.
- Prevent a single touch from accidentally triggering multiple actions.
- If keyboard controls are useful during desktop development, support left/right, rotate, soft drop, hard drop, and pause without making keyboard support a release requirement.

## 4. Scoring and difficulty

Use a familiar, transparent scoring model. Suggested initial values:
- 1 line: 100 × current level.
- 2 lines: 300 × current level.
- 3 lines: 500 × current level.
- 4 lines: 800 × current level.

These values are configurable; do not bury them throughout the code.

- Track score, total lines cleared, and current level.
- Increase level at a defined line-clear threshold, such as every 10 lines.
- Increase falling speed gradually with level.
- Set a minimum fall interval so the game remains playable.
- Show the player how the level is progressing.

Do not add combo, back-to-back, or complex bonus systems in version 1 unless the core implementation is already stable.

## 5. Pause and game-over

- Pause freezes automatic falling and ignores gameplay input.
- Resume restores the previous state without resetting the board.
- Restart starts a fresh game and resets current score/lines/level.
- Game over occurs when a new piece cannot spawn safely.
- Best score is updated when a game ends or when the current score exceeds it, using a single clear rule.
- Returning to the menu must not leave timers or input handlers running in the background.

## 6. Persistence and settings

Save locally:
- Best score.
- Sound enabled/disabled.
- Any additional setting only if it is actually implemented.

Use Godot's user data directory and a simple, version-tolerant save format. Handle missing or malformed save data safely. The game must still start if no save file exists.

## 7. Accessibility and usability

- Provide sufficiently large touch targets.
- Maintain contrast between pieces, board, and UI.
- Do not rely on color alone to explain controls or state.
- Make pause and restart actions easy to find.
- Avoid requiring precise swipe gestures for essential actions.

## 8. Testing cases

Test at least:
- Movement against each board wall.
- Rotation near walls and occupied cells.
- Landing on the floor and on other pieces.
- Clearing one, two, three, and four lines where supported by the piece system.
- Multiple line clears at once.
- Spawn blocked / game over.
- Pause and resume while a piece is falling.
- Restart after game over.
- Best-score save and reload.
- Fast repeated touch input.
- App backgrounding and returning, especially while paused.
