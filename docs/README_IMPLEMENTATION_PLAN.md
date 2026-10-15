# Implementation Plan and AI Coding Rules

## 1. Goal

Use the accompanying README files as the product specification while building the game in Godot 4.x. The developer is new to Godot, so the project should remain understandable enough to learn from—not merely compile after a one-shot generation.

## 2. Build order (MVP1)

Each phase ends with `make test` and `make backend-test` passing. Status below is what the code shows today. The backend is **not deployed** yet.

### Original phases 1–6, 9, 10 — code done
- 1 Project skeleton, 2 Logical board and pieces, 3 Falling and locking, 4 Line clears and scoring, 5 Touch UI and game states, 6 Persistence and polish: implemented and covered by unit tests.
- 9 Sync backend (FastAPI, auth, `max()` merge, leaderboard, deletion) and 10 Sync client (`Sync` autoload, sign-in, profile, leaderboard screens): implemented and tested. Deployment from Phase 9 moved to Phase C.
- Phase 7 (Android validation) and Phase 8 (release preparation) moved to Phases E and F.

### Phase A — Docs: done
Every doc describes the code as it is now.

### Phase B — Functional alignment: done in code, not device-verified
- Start-level picker works: the levels screen starts real games; level N unlocks at 10 × (N − 1) lifetime lines; in-run level is `max(start, lines / 10 + 1)`.
- Server URL is a project setting with a `.release` override; an empty URL hides online features.
- Android export has INTERNET and VIBRATE.
- DevicePreview is guarded to desktop debug runs.
- Still to verify: a debug APK on a phone syncs over LAN and vibrates (Phase E).

**Checkpoint:** levels start real games; debug APK on a phone syncs over LAN and vibrates.

### Phase C — Backend live: code done, deploy not done
- Done in code: username blocklist, sync plausibility check, `/privacy` and `/account/delete` pages, production secret guard, `render.yaml`, [DEPLOY.md](DEPLOY.md).
- Not done: create the Neon database and the Render service, set secrets, deploy, set the release API URL in `game/project.godot`, run the smoke test against production (register, sync, leaderboard, delete).
- Keep exactly one instance (in-memory rate limits).

**Checkpoint:** production smoke test passes; privacy and deletion pages reachable over HTTPS.

### Phase D — Redesign: in progress (analysis only)
- Implement MasterPrompt phases 1–5 on the MVP1 screen set. No redesign code yet.
- Then rewrite `README_VISUAL_DESIGN.md` from the result.

**Checkpoint:** the MasterPrompt acceptance checklist passes. C can run in parallel with D.

### Phase E — Device validation: not started
- Android export, debug APK, real-device checks: touch, aspect ratios, performance, background/resume, safe areas.
- Run the sync test cases in `README_GAMEPLAY_FEATURES.md` against production, online and in airplane mode.

**Checkpoint:** full test pass on at least two real phones with different aspect ratios.

### Phase F — Release: not started
- App icon, screenshots from the redesigned build, store text, data safety form, signing, target API level, package ID and versioning.
- Use Google Play's current requirements. Do not pay for a developer account until the build is worth publishing.

**Checkpoint:** an internal testing track build installed from Play.

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
- [ ] Main menu Play button works (starts at level 1).
- [ ] Start-level picker: locked levels cannot start a game; an unlocked level starts at that level.
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
- [ ] Docs describe the shipped app with no contradictions.
- [ ] Audio mute works.
- [ ] No network access is required for the core game (sync features are optional and fail silently offline).
- [ ] A build with an empty server URL hides online features and makes no requests.
- [ ] Release build points at an HTTPS URL.
- [ ] Account deletion works in the app and on the web page.
- [ ] Haptics vibrate and sync works on a real phone (INTERNET and VIBRATE permissions).
- [ ] No unimplemented buttons or fake settings remain.

## 5. First task for the coding assistant

Start by inspecting the project directory and all README files. Then:
1. State any genuine specification conflicts or missing essentials.
2. Create the smallest runnable Godot project.
3. Implement the core game loop before visual polish.
4. Keep the code readable and explain the key Godot concepts used.
5. Finish with exact instructions for opening the project, running it in the editor, and testing it.
