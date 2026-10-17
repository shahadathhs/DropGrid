# Project Overview — Falling-Block Puzzle

> **Title:** DropGrid

## 1. Project goal

Build a polished, lightweight 2D falling-block puzzle game for Android using **Godot 4.x** and **GDScript**.

The first release should feel complete and intentional rather than like a tutorial demo. Prioritize responsive controls, clear visual feedback, smooth animations, readable UI, and reliable gameplay.

## 2. Target platform

- **Primary platform:** Android phones.
- **Secondary platforms:** Desktop (Windows/macOS/Linux) via the same Godot project. Used for development and the debug phone-size simulator; not an MVP1 release target.
- **Engine:** Godot 4.x.
- **Language:** GDScript.
- **Orientation:** Portrait.
- **Connectivity:** Offline-first; the core game must work without an internet connection. Accounts and cross-device sync are optional and make no difference to guests.
- **Initial business model:** Free, with no ads or purchases.
- **Save data:** Local device storage as the source of truth; optional server sync for account holders.

Design and test for different phone aspect ratios and screen sizes. Avoid assuming one exact resolution.

## 3. Product principles

1. **Easy to understand:** A player should understand the board and controls within seconds.
2. **Responsive:** Inputs should feel immediate; avoid unnecessary delays or complicated gestures.
3. **Readable:** The active piece, landed blocks, ghost/landing preview if included, and board boundaries must be distinguishable.
4. **Focused:** Gameplay is the main event. UI and effects should support it, not compete with it.
5. **Small and dependable:** Keep the first release self-contained and avoid unnecessary dependencies.
6. **Maintainable:** Separate board rules, piece logic, game flow, input, UI, and local persistence.

## 4. MVP1 scope

MVP1 is the first public Google Play release. It contains:

1. **The core game, fully offline.** Menu, play, pause, game over, restart. Local best score, sound, haptics.
2. **A start-level picker.** Players can start a game at any level they have unlocked (levels 1 to 10). Level N unlocks when lifetime lines cleared reach 10 × (N − 1). This is a simple lines threshold, not a complex unlock system.
3. **Optional accounts and a global leaderboard.** Email + password with a username, background sync of best score, total lines, and games played, a profile screen, and a top-50 leaderboard. Signing in on another device brings the stats and unlocked levels across. Runs on one small FastAPI backend with one SQL database.
4. **The visual redesign** to the Cell Unit design system, described in [README_VISUAL_DESIGN.md](README_VISUAL_DESIGN.md).

Included in the core game:

- Main menu.
- Playable game screen.
- Falling pieces, movement, rotation, collision, locking, and line clearing.
- Score, cleared-line count, and increasing difficulty.
- Pause/resume.
- Game-over screen and restart.
- Locally saved best score.
- Touch-friendly Android controls.
- Sound effects and haptics, each with an on/off setting.

**Principles for accounts and sync:**

- Guest play is a complete, first-class experience with zero network calls.
- Local save stays the source of truth for gameplay; sync never blocks or breaks a session.
- A build with no server URL set hides every online feature and makes no requests.
- No ads, analytics, or third-party SDKs.
- There is no password reset in MVP1. Losing an account loses only the synced copy; local stats stay.

**Scope update (2026-10-17):** hold piece, game modes, timers, and the daily seeded challenge are **now included** — the original exclusions below were amended when the mode system shipped. Still **not included:** multiplayer and other social features, ads, in-app purchases, daily missions, achievements, skins or themes beyond the two built-in grounds, battle pass, password reset, passwordless/OTP sign-in, XP/seasons/rating systems, real anti-cheat.

**Included by amendment:** hold piece; a 3-piece next queue; lock delay with move resets; combo and back-to-back scoring; five modes — Marathon, Sprint (40 lines), Ultra (2 minutes), Daily (one shared UTC-seeded run), Zen (no game over); per-category leaderboards (sprint ranks by time, daily resets every UTC day, Zen earns nothing); a stats screen; music and an expanded settings set (ground, ghost piece, left-handed, large buttons).

The path to release is in [README_IMPLEMENTATION_PLAN.md](README_IMPLEMENTATION_PLAN.md). Backend deployment is described in [DEPLOY.md](DEPLOY.md).

## 5. Definition of done

MVP1 is ready for release when:

- A complete game can be played from menu to game over and restarted.
- Pieces cannot move or rotate through occupied cells or board boundaries.
- Line clearing and score updates work consistently.
- Pause stops gameplay correctly.
- Best score persists after closing and reopening the app.
- Touch controls work on a real Android device.
- UI remains usable on more than one screen aspect ratio.
- No debug controls, placeholder text, or obvious unfinished screens remain.
- A guest can play every feature except the leaderboard and profile with no network calls (verify with airplane mode).
- A signed-in player's stats and unlocked levels appear on a second phone.
- Account deletion works in-app and from the web page.
- No fake buttons, placeholder text, or settings that do nothing.
- Docs describe the shipped app with no contradictions.
