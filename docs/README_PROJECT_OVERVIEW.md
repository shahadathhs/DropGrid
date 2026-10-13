# Project Overview — Falling-Block Puzzle

> **Working title:** Dropgrid  
> The title is temporary and can be changed after checking name availability.

## 1. Project goal

Build a polished, lightweight 2D falling-block puzzle game for Android using **Godot 4.x** and **GDScript**.

The first release should feel complete and intentional rather than like a tutorial demo. Prioritize responsive controls, clear visual feedback, smooth animations, readable UI, and reliable gameplay.

## 2. Target platform

- **Primary platform:** Android phones.
- **Secondary platforms:** Desktop (Windows/macOS/Linux) via the same Godot project, unlocked by the account backend; not a version-1 requirement.
- **Engine:** Godot 4.x.
- **Language:** GDScript.
- **Orientation:** Portrait.
- **Connectivity:** Offline-first; the core game must work without an internet connection. Accounts and cross-device sync are optional additions on top.
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

## 4. First-release scope

Include:
- Main menu.
- Playable game screen.
- Falling pieces, movement, rotation, collision, locking, and line clearing.
- Score, cleared-line count, and increasing difficulty.
- Pause/resume.
- Game-over screen and restart.
- Locally saved best score.
- Touch-friendly Android controls.
- Basic sound effects with a mute option.
- Settings for sound and haptics only if haptics can be implemented reliably.

Do not include in version 1:
- Multiplayer.
- Ads or in-app purchases.
- Daily missions, achievements, skins shop, or battle pass.
- Complex unlock systems.

Version 1 remains fully offline. A following release adds optional accounts and sync:

**Sync release includes:**
- Optional account (email + password) with username.
- Background sync of best score, total lines cleared, and games played after signing in.
- Global leaderboard (top 50 by best score) and a personal profile screen.
- Cross-device progress: sign in on another device and the stats appear.
- Desktop builds as a secondary platform, unlocked by having one shared backend.

**Sync release principles:**
- Guest play is a complete, first-class experience with zero network calls.
- Local save stays the source of truth for gameplay; sync never blocks or breaks a session.
- One small FastAPI backend service and one SQL database — no ads, analytics, or third-party SDKs.

**Still excluded:** multiplayer, ads, in-app purchases, daily missions, achievements, battle pass, passwordless/OTP sign-in, XP/seasons/rating systems.

## 5. Definition of done

The game is ready for a first external test when:
- A complete game can be played from menu to game over and restarted.
- Pieces cannot move or rotate through occupied cells or board boundaries.
- Line clearing and score updates work consistently.
- Pause stops gameplay correctly.
- Best score persists after closing and reopening the app.
- Touch controls work on a real Android device.
- UI remains usable on more than one screen aspect ratio.
- No debug controls, placeholder text, or obvious unfinished screens remain.
