# Implementation Plan and AI Coding Rules

## 1. Goal

Use the accompanying README files as the product specification while building the game in Godot 4.x. The developer is new to Godot, so the project should remain understandable enough to learn from—not merely compile after a one-shot generation.

## 2. Build order

### Phase 1 — Project skeleton
- Create the Godot project with portrait orientation.
- Create a simple main menu and game scene.
- Confirm the project runs in the editor.
- Use temporary shapes if final art is not ready.

**Checkpoint:** The app opens and Play enters the game scene.

### Phase 2 — Logical board and pieces
- Implement the logical grid and piece definitions.
- Render the board and active piece.
- Implement left/right movement and collision checks.
- Implement rotation and collision checks.

**Checkpoint:** The active piece moves and rotates without crossing walls or occupied cells.

### Phase 3 — Falling and locking
- Add timed falling.
- Lock pieces when downward movement is blocked.
- Spawn the next piece.
- Detect blocked spawn/game over.

**Checkpoint:** A complete basic game loop works.

### Phase 4 — Line clears and scoring
- Detect full rows.
- Clear them and shift rows correctly.
- Update score, total lines, and level.
- Increase fall speed within defined limits.

**Checkpoint:** Several consecutive line clears do not corrupt the board.

### Phase 5 — Touch UI and game states
- Add touch controls.
- Add pause/resume and restart.
- Add game-over screen and menu navigation.
- Ensure timers and inputs stop in paused/game-over states.

**Checkpoint:** The game can be played entirely with touch on a phone.

### Phase 6 — Persistence and polish
- Save/load best score and sound setting.
- Add short sound effects and subtle animations.
- Improve typography, spacing, feedback, and transitions.
- Add a mute option.

**Checkpoint:** The game feels coherent rather than like a raw prototype.

### Phase 7 — Android validation
- Configure the Android export template and export settings.
- Build a debug APK and install it on a real Android device.
- Check touch behavior, aspect ratios, performance, background/resume behavior, and safe areas.
- Fix crashes and high-priority usability problems before store preparation.

**Checkpoint:** A real device test passes from launch through multiple games.

### Phase 8 — Release preparation
- Create the app icon and store screenshots.
- Write a concise store description and privacy information appropriate to the actual app.
- Verify package ID, versioning, orientation, and permissions.
- Use Google Play's current requirements for signing, target API level, testing, and release.
- Do not pay for a developer account until the prototype is worth publishing.

### Phase 9 — Sync backend
- Scaffold `backend/` with FastAPI, SQLAlchemy, and Alembic (SQLite in dev, PostgreSQL in production).
- Implement `/v1` auth (register, login, refresh; bcrypt + JWT), players, the `max()` stats merge on `POST /v1/sync`, the top-50 leaderboard, and account deletion.
- Cover auth, the merge rule, and leaderboard ordering with backend tests.
- Add `make backend-install|run|test` targets and a compose service for local dev.
- Deploy one instance (Fly.io/Railway or similar) behind HTTPS.

**Checkpoint:** `curl` proves register → sync → leaderboard against a deployed instance.

### Phase 10 — Sync client
- Add the `sync` autoload (tokens, outbox, retry/backoff); gameplay code stays network-free.
- Add sign-in/registration, profile, and leaderboard screens using `ui-prototype/` as the visual reference.
- Wire sync triggers: after sign-in, after game over, on app background, on app start.
- Verify guest paths make zero network calls and every failure path fails silently.

**Checkpoint:** on a real device, online and offline: register, play, see stats on a second device, appear on the leaderboard, delete the account — with no crash, dialog, or blocked gameplay at any point without network.

## 3. One-shot implementation strategy

An AI coding assistant may be asked to scaffold and implement the full game, but it must:
1. Read all project README specifications first.
2. Confirm the exact Godot 4.x version and use matching APIs.
3. Generate real, internally consistent scenes and scripts—not only code snippets.
4. Avoid placeholder methods that pretend a feature works.
5. Keep dependencies and project scope minimal.
6. Explain the project structure and the key game loop after implementation.
7. Provide a manual test checklist and identify anything not verified.
8. Never claim it ran Godot, exported an APK, or tested on a phone unless it actually did so.

If a one-shot implementation becomes too tangled, fix it in small phases instead of adding more code on top of broken code.

## 4. Verification checklist

- [ ] Project opens without parse errors.
- [ ] Main menu Play button works.
- [ ] Piece movement and rotation work.
- [ ] Board boundaries and collision rules hold.
- [ ] Timed falling and locking work.
- [ ] Completed lines clear correctly.
- [ ] Score, lines, and level update correctly.
- [ ] Pause actually freezes the game.
- [ ] Restart fully resets the current game.
- [ ] Game over occurs at the correct time.
- [ ] Best score persists across app restarts.
- [ ] Touch controls work on a real Android device.
- [ ] UI works on more than one aspect ratio.
- [ ] Audio mute works.
- [ ] No network access is required for the core game (sync features are optional and fail silently offline).
- [ ] No unimplemented buttons or fake settings remain.

## 5. First task for the coding assistant

Start by inspecting the project directory and all README files. Then:
1. State any genuine specification conflicts or missing essentials.
2. Create the smallest runnable Godot project.
3. Implement the core game loop before visual polish.
4. Keep the code readable and explain the key Godot concepts used.
5. Finish with exact instructions for opening the project, running it in the editor, and testing it.
