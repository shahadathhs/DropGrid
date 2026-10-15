# MVP1 Plan — Synced Scope

Status: agreed 2026-10-15. This file is the source of truth for MVP1 until Phase A below folds it into the other docs. After that, delete this file.

## 1. What MVP1 is

The first public Google Play release contains:

1. **The core game, fully offline.** Menu → play → pause → game over → restart. Local best score, sound, haptics.
2. **A start-level picker.** Players can start a game at any level they have unlocked. Levels unlock from lifetime lines cleared.
3. **Optional accounts and a global leaderboard.** Email + password, background stat sync, profile, top 50. Runs on a deployed HTTPS backend. Guests never touch the network.
4. **The visual redesign** from [MasterPrompt.md](../MasterPrompt.md).

Not in MVP1: hold piece, timers or other modes, password reset, social features, ads, purchases, achievements, themes.

## 2. Where docs and code disagree today

| # | Topic | Docs say | Code does | Resolution |
|---|---|---|---|---|
| 1 | Release scope | Overview: "Version 1 remains fully offline", accounts in a later release | Accounts, sync, profile, leaderboard fully built | Docs change: MVP1 includes accounts (section 1) |
| 2 | Levels screen | Overview excludes "complex unlock systems"; no doc mentions it | `levels.tscn` shows 12 nodes; every node starts a normal level-1 game (a fake button) | Make it real (section 4.1); docs describe it |
| 3 | Dev database | Architecture: SQLite in dev | Postgres in Docker locally, Neon in production; SQLite still works as a fallback | Docs change |
| 4 | Project tree | Lists `piece_view.gd`, `resources/piece_definitions.gd` | Neither exists; there are 4 autoloads (`Save`, `Sfx`, `Sync`, `DevicePreview`) and about 25 scripts | Rewrite tree from the real files |
| 5 | Phase status | Implementation plan lists Phases 9–10 like finished work | Backend never deployed; Phase 7 (device) and 8 (release) not done | Replace phase list with section 5 |
| 6 | Android permissions | Haptics and sync are in scope | `export_presets.cfg` has neither INTERNET nor VIBRATE enabled; both fail silently on a phone | Enable both |
| 7 | Server URL | Production behind HTTPS | `API_BASE_URL` hardcoded to `http://localhost:8000/v1` | Per-build URL (section 4.2) |
| 8 | DevicePreview | Not documented | Desktop-only autoload, F9/F10 size cycling | Document as a dev tool; confirm it is inert in Android builds |
| 9 | Main menu | Title, Play, Settings, best score | Also Levels, Leaderboard, Sign in/Profile, "Continue as guest" | Redesign decides the final menu; docs follow the result |
| 10 | Visual spec | `README_VISUAL_DESIGN.md` describes the old dark palette | Same, but MasterPrompt replaces it | Rewritten in Phase D, not before |

## 3. Decisions taken by default (change them here if you disagree)

- **Unlock rule:** level N unlocks when lifetime `total_lines >= 10 × (N − 1)`. This is the rule `levels_screen.gd` already uses and tests. `total_lines` already syncs, so signing in on a new phone carries unlocks over with no new server field.
- **Start levels offered:** 1 to 10 (`GameConfig.MAX_START_LEVEL`). Above that the speed is near the floor, so more choices add nothing.
- **Level during a game:** `level = max(start_level, lines_this_game / 10 + 1)`. Scoring keeps the existing `points × level` rule, so starting higher scores more. This is the classic trade of risk for points and is fair for the leaderboard.
- **Play on the main menu** starts at level 1. The levels screen is the only way to start higher.
- **No password reset in MVP1.** Losing an account loses only the synced copy; local stats stay. Write this as a known limitation in the privacy and help text.
- **Scores stay trusted.** Add only a cheap server plausibility check (section 4.3). Real anti-cheat is out of scope.

## 4. Work items

### 4.1 Levels made real
- Pass the chosen start level from the levels screen into the game scene (one small holder read in `game.gd`).
- `GameController` takes `start_level` and applies the level rule from section 3.
- Locked levels cannot be pressed. Unlocked ones show their fall speed or level number only, with no fake progress decoration.
- Tests: start at level 5 → fall interval and score multiplier match level 5; clearing 10 lines from level 5 keeps level 5 until lines this game pass 50; a locked node cannot start a game.

### 4.2 Android and builds
- Enable `permissions/internet` and `permissions/vibrate` in `export_presets.cfg`.
- Move `API_BASE_URL` to a project setting with a `.release` feature-tag override: debug builds use the LAN/emulator URL, release builds use the HTTPS production URL. Release must never point at `http://`.
- Check that DevicePreview does nothing on Android.

### 4.3 Backend to production
- Deploy one instance (Fly.io, Railway, or Render) with Neon Postgres, HTTPS, and migrations run on deploy.
- Set real secrets (JWT key) through the host's secret store, never committed.
- Rate limits are in-memory: keep exactly one instance, and write that down.
- Username blocklist on register and rename: the leaderboard shows usernames publicly.
- Plausibility check on `POST /v1/sync`: reject a `best_score` above what `total_lines` could produce at the maximum level.
- **Account deletion web page.** Google Play requires a web link where users can request deletion, in addition to the in-app button. A small page served by the backend (sign in → delete) satisfies this.
- **Privacy policy page.** Required because the app collects email. State: email, username, three stats; no ads, no analytics, no third parties; how to delete.
- Smoke test against production: register → sync → leaderboard → delete.

### 4.4 Docs synced (Phase A)
- `README_PROJECT_OVERVIEW.md`: replace the v1 / sync-release split with the MVP1 scope from section 1. Move the "still excluded" list there.
- `README_GAMEPLAY_FEATURES.md`: add start level and unlock rule; fold the sync section into the main spec.
- `README_ARCHITECTURE.md`: real file tree, autoloads, Postgres/Neon, per-build API URL, DevicePreview.
- `README_IMPLEMENTATION_PLAN.md`: keep sections 3–4 (AI coding rules, checklist); replace the phase list with section 5 of this file, marking finished phases as done.
- `README.md`: one status line pointing at MVP1.
- `MasterPrompt.md`: screen list matches MVP1 (done 2026-10-15).

## 5. Order

Each phase ends with `make test` and `make backend-test` passing.

| Phase | Work | Done when |
|---|---|---|
| **A. Docs** | 4.4 | Every row of the table in section 2 is resolved in the docs; no doc mentions a file that does not exist |
| **B. Functional alignment** | 4.1, 4.2 | Levels start real games; debug APK on a phone syncs over LAN and vibrates |
| **C. Backend live** | 4.3 | Production smoke test passes; privacy and deletion pages reachable over HTTPS |
| **D. Redesign** | MasterPrompt phases 1–5 on the MVP1 screen set; then rewrite `README_VISUAL_DESIGN.md` from the result | MasterPrompt acceptance checklist passes |
| **E. Device validation** | Old Phase 7, plus the sync test cases in `README_GAMEPLAY_FEATURES.md` against production | Full test pass on at least two real phones with different aspect ratios, online and in airplane mode |
| **F. Release** | Old Phase 8: icon, screenshots from the redesigned build, store text, data safety form, signing, target API level | Internal testing track build installed from Play |

B goes before D on purpose: the redesign should not chase screens that are still changing. C can run in parallel with D.

## 6. MVP1 definition of done

- Everything in the overview's definition of done.
- A guest can play every feature except the leaderboard and profile with no network calls (verify with airplane mode).
- A signed-in player's stats and unlocked levels appear on a second phone.
- Account deletion works in-app and from the web page.
- No fake buttons, placeholder text, or settings that do nothing.
- Docs describe the shipped app with no contradictions; this file is deleted.
