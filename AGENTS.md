# AGENTS.md

Instructions for AI coding agents working in this repository.

## Project

DropGrid: a portrait falling-block puzzle game for Android, built with **Godot 4.7 + GDScript** (`game/`), plus an optional **FastAPI** backend for accounts, stats sync, and a leaderboard (`backend/`). Offline-first: guest play makes zero network calls, and sync fails silently when offline. Monorepo — see `docs/README_ARCHITECTURE.md` for details.

Read `docs/README_PROJECT_OVERVIEW.md` for scope. Do not add features from its "not included" list, and do not change gameplay for visual reasons. Never claim you ran Godot, exported an APK, or tested on a phone unless you actually did.

## Branching

All changes go through **`dev`** → pull request → merge into `main`. Merges to `main` trigger the CI/CD pipeline (Render deploy, APK, rolling `latest` release); `v*` tags produce versioned releases. Keep `dev` fast-forwarded to `main` after each merge.

## Commands

The `Makefile` is the command surface. Headless Godot runs in Docker (`make` wraps `docker compose run`); the backend uses [uv](https://docs.astral.sh/uv/).

```sh
make check          # load the game headless; fails on parse/script errors
make test           # run GUT unit tests (game/tests/)
make lint           # GDScript style gate: gdlint + gdformat --check (config: gdlintrc)
make format         # fix GDScript style in place (gdformat)
make apk            # export a debug APK to game/build/
make backend-test   # pytest (run from repo root; cds into backend/)
make backend-lint   # ruff check
make backend-format # ruff format + autofix
make backend-typecheck # pyright
make backend-run    # serve API at http://localhost:8000 (needs db: make db-up)
make run            # play the game on this PC (host Godot)
make run-game       # run straight into the game scene
```

After changing game code, run `make lint`, `make check`, and `make test` — formatting is enforced (`gdformat`), so run `make format` if lint complains. After changing backend code, run `make backend-lint`, `make backend-typecheck`, and `make backend-test`. Docs in `docs/` must match the code; update them in the same change when behavior changes.

## Game architecture — do not break

- **Model / view separation.** `BoardModel` and `GameController` (`game/scripts/`) hold all rules and state as pure logic and communicate via signals. Scenes wire signals to views. Keep logic testable without a scene tree; constructors accept seeds and injectable paths for deterministic tests.
- **One place per kind of style.** Every color comes from `game/scripts/palette.gd`; every style comes from `game/scripts/game_theme.gd` via `theme_type_variation`. No scene or other script defines a `Color`, a font, or inline styling. A grep for `Color(` outside the palette should fail.
- **Tuning constants live in `game/scripts/game_config.gd`** (board size, fall intervals, scoring, limits). Do not hardcode them elsewhere; the backend mirrors some of them in `backend/core/game_limits.py` — keep both sides consistent.
- **`Sync` autoload is the only network code.** Signed-out (guest) play must make no requests. Network failure is silent and retried in the background.
- **Tests:** GUT, in `game/tests/`. Backend tests: `backend/tests/` (pytest, throwaway SQLite).

## Visual rules (the house style)

The design system is **Cell Unit** — the board's square cell is the unit for spacing, sizing, and style; rules live in `docs/README_VISUAL_DESIGN.md`. When touching UI:

- No two-tone headlines, taglines, motivational copy, eyebrow labels, or questions to the player. Short game-voice labels: "Paused", "Game over", "Best", "Play again". No exclamation marks.
- No card inside a card, no border where spacing would do, no glow, gradients, frosted glass, or particle decoration.
- Exactly one primary button per screen. Score digits use tabular numerals and never shift width.
- Piece colors must stay distinguishable in grayscale.
- Animations at most 250 ms (game over may be longer); nothing loops while idle.
- Prefer deleting to adding. If unsure between two options, build both small and show them rather than asking in the abstract.

## Screenshots (verify before you claim)

You cannot judge a design you have not seen. `DevicePreview` (desktop debug builds only) supports:

```sh
godot --path game -- --shot=/tmp/shot.png --size=390x844 --demo
```

Capture at **390×844**, **360×640**, and **412×915**; use `--demo` for a board with pieces, a ghost, and a non-zero score. Look at each screenshot yourself and list what is wrong before reporting.

## Backend notes

- Async FastAPI + SQLAlchemy 2 async + Alembic migrations; JWT auth (30 min access / 30 day refresh, `password_version` claim); bcrypt.
- The rate limiter is in-process: the production service must stay a single instance.
- Lint: ruff, line length 100, target py312 (rules E,F,I,UP,B,SIM,C4,RUF). Types: pyright, standard mode (`backend/pyrightconfig.json`).
