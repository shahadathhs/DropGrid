# After Drop

A polished, lightweight 2D falling-block puzzle game built with **Godot 4.x** and **GDScript**. Portrait, offline-first, no ads or purchases. Optional accounts and a leaderboard run on a small FastAPI backend (Phases 9–10).

> Working title: Dropgrid (temporary).

## Repository layout

```text
game/           Godot project (scenes, scripts, assets, tests)
backend/        FastAPI service: accounts, stats sync, leaderboard
ui-prototype/   Next.js mockup of the screens (visual reference only)
docs/           Specifications
docker/         Container helper scripts (Godot image entrypoint, Android setup)
```

## Status

Playable prototype. Board logic, touch UI, sound, and local saves are in; Android device validation (Phase 7 of the [implementation plan](docs/README_IMPLEMENTATION_PLAN.md)) is pending. Next up: the sync release — optional accounts and a leaderboard on a FastAPI backend (Phases 9–10).

## Docs

- [Project overview](docs/README_PROJECT_OVERVIEW.md): goals, scope, definition of done
- [Architecture](docs/README_ARCHITECTURE.md): structure, responsibilities, state model
- [Gameplay and features](docs/README_GAMEPLAY_FEATURES.md): loop, controls, scoring, persistence
- [Visual design](docs/README_VISUAL_DESIGN.md): theme, colors, layout, sound
- [Implementation plan](docs/README_IMPLEMENTATION_PLAN.md): build phases and verification checklist

## Development

Headless Godot runs in Docker via `docker compose`; the backend uses [uv](https://docs.astral.sh/uv/); the UI prototype uses pnpm.

```sh
make help          # list targets
make check         # import and parse-check the game
make test          # run game unit tests
make apk           # export game/build/afterdrop-debug.apk
make install       # adb install to a USB-connected phone (brew install --cask android-platform-tools)
make backend-run   # serve the backend at http://localhost:8000 (docs at /docs)
make ui-dev        # serve the UI prototype at http://localhost:3000
```

## UI prototype

A clickable Next.js mockup of the game's screens lives in [ui-prototype/](ui-prototype/) (v0 export; design reference only, not part of the game build).

```sh
make ui-install   # once (needs pnpm)
make ui-dev       # serve at http://localhost:3000
```
