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
- Rotation must handle wall/floor collisions safely. Basic rotation is sufficient for MVP1; implement wall kicks only if needed for a reliable feel.
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

## 3b. Hold, next queue, and lock delay

- **Hold:** one swap per spawned piece; holding again does nothing until the next piece locks. The hold slot starts empty; holding with an empty slot stashes the piece and spawns the next.
- **Next queue:** the HUD shows the next three pieces in bag order.
- **Lock delay:** a landed piece waits 0.5 s (LOCK_DELAY) before locking. A successful move or rotation resets the timer, at most 15 times per piece (MAX_LOCK_RESETS); gravity stepping past a ledge also resets it.
- **Time:** the HUD shows elapsed time (mm:ss). Ultra counts down instead.

## 3c. Modes

| Mode     | Rules                                                          | Leaderboard                         |
| -------- | -------------------------------------------------------------- | ----------------------------------- |
| Marathon | Classic survival, start level 1-10                             | Best score, all time                |
| Sprint   | Clear 40 lines; the run ends as a win                          | Time to 40, lower is better         |
| Ultra    | 2-minute score attack                                          | Best score, all time                |
| Daily    | Marathon rules, piece order seeded by the UTC date (YYYYMMDD)  | Best score of the day; resets daily |
| Zen      | No game over: a full board sheds everything and play continues | None                                |

## 4. Scoring and difficulty

Use a familiar, transparent scoring model. Live values (GameConfig):

- 1 line: 100 × current level.
- 2 lines: 300 × current level.
- 3 lines: 500 × current level.
- 4 lines: 800 × current level.
- **Combo:** each lock that clears lines in an unbroken chain adds 50 × combo × level (the first clear of a chain adds nothing).
- **Back-to-back:** a tetris immediately after another tetris scores × 1.5.

These values are configurable; do not bury them throughout the code. The server mirrors the ceiling in backend/core/game_limits.py — change both together.

- Track score, total lines cleared, and current level.
- Increase level every 10 lines cleared in the current game.
- Increase falling speed gradually with level.
- Set a minimum fall interval so the game remains playable.
- Show the player how the level is progressing.

Do not add combo, back-to-back, or complex bonus systems in MVP1 unless the core implementation is already stable.

### Start level and unlocks

- The levels screen is a start-level picker. The player chooses a start level from 1 to 10.
- Level N unlocks when lifetime lines cleared (`total_lines`, summed over all games) reach 10 × (N − 1). Level 1 is always open.
- Locked levels cannot be pressed. Each card shows the level's drop interval, or "Unlocks at N lines" while locked. The newest unlocked level is highlighted.
- In a run, `level = max(start_level, lines_this_game / 10 + 1)`. Starting at level 5 keeps level 5 until 50 lines are cleared in that game.
- Scoring is unchanged (points × level), so starting higher scores more. Fall speed follows the level.
- Play on the main menu always starts at level 1. Play Again after game over repeats the run's start level.
- `total_lines` already syncs, so unlocks carry over when the player signs in on a new phone.
- Levels above 10 are not offered: the fall speed is near its floor.

## 5. Pause and game-over

- Pause freezes automatic falling and ignores gameplay input.
- Resume restores the previous state without resetting the board.
- Restart (Play Again on the game-over screen) starts a fresh game and resets current score/lines/level.
- Game over occurs when a new piece cannot spawn safely.
- Best score is updated when a game ends or when the current score exceeds it, using a single clear rule.
- Returning to the menu must not leave timers or input handlers running in the background.

## 6. Persistence and settings

Save locally:

- Best score.
- Sound enabled/disabled.
- Any additional setting only if it is actually implemented.

Use Godot's user data directory and a simple, version-tolerant save format. Handle missing or malformed save data safely. The game must still start if no save file exists.

## 6b. Accounts and sync (optional, part of MVP1)

Optional account features layered on top of local persistence. Guests never touch the network.

- Sign in / register with email, password, and username; or keep playing as a guest.
- Username: 3 to 20 characters, letters, digits, and underscore. Names that match the blocklist (reserved names, slurs, and profanity) are rejected on register and rename, because the leaderboard shows usernames publicly. Matching: terms of 5 or more letters match anywhere in the name; shorter terms match only as a whole name or a whole part split at `_`. Simple digit swaps (such as 0 for o) are normalised first.
- After each game ends, stats (best score, total lines, games played) sync to the player's account in the background.
- The server keeps the max of each stat, so offline play and multiple devices converge without conflicts.
- The server rejects a sync (HTTP 422) whose stats are not plausible: games played is 0 while lines or score is above 0, or best score is above what the submitted total lines could produce. The client treats this as a failed sync and stays silent. Scores are otherwise trusted; there is no real anti-cheat.
- Screens: sign-in/registration form, profile with synced stats, rename, sign-out and delete account, global leaderboard (top 50).
- Sync runs after sign-in, after game over, on app background, and on app start.
- Every account feature fails silently offline: no dialogs, no blocked gameplay.
- A build with no server URL set (project setting `dropgrid/network/api_base_url`) hides the account and leaderboard entries and "Continue as guest", and Sync makes no requests.
- "Continue as guest" shows only when online features are on and the player is signed out. It plays exactly like Play.
- There is no password reset in MVP1. Losing an account loses only the synced copy; local stats stay. State this in the privacy and help text.
- Account deletion works in the app (profile screen) and on a web page served by the backend (`/account/delete`).

## 7. Accessibility and usability

- Provide sufficiently large touch targets.
- Maintain contrast between pieces, board, and UI.
- Do not rely on color alone to explain controls or state.
- Make pause and Play Again easy to find.
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
- Start level: level 1 always open; level N locked until lifetime lines reach 10 × (N − 1); a locked level cannot start a game.
- Start at level 5: the fall interval and score multiplier match level 5, and the level stays 5 until 50 lines are cleared in that game.
- Play from the main menu after a higher-level run: starts at level 1. Play Again: repeats the run's start level.
- Fast repeated touch input.
- App backgrounding and returning, especially while paused.

Sync cases (run against the deployed backend):

- Register, sign out, sign in on a second device — stats appear.
- Play offline with an account, then sync on reconnect — server takes the max.
- Airplane mode during game over — no crash, no dialog, stats stay local.
- Expired access token mid-sync — transparent refresh, no lost submission.
- Register with a blocked username — rejected with a clear message; username shorter than 3 or longer than 20 — rejected.
- Sync with games played 0 but lines or score above 0 — rejected with 422, local stats untouched.
- Sign in on a second device — total lines and unlocked levels appear.

Offline-build cases:

- A build with an empty server URL: no Sign in, Leaderboard, or Continue as guest entries, and no network requests (check with airplane mode and with the empty setting).
- Debug build on a phone: haptics vibrate and sync works over the LAN (needs the INTERNET and VIBRATE permissions in the export).
- Release build: the server URL is HTTPS, never `http://`.
