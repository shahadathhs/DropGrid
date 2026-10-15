# DropGrid

A polished, lightweight 2D falling-block puzzle game built with **Godot 4.x** and **GDScript**. Portrait, offline-first, no ads or purchases. Optional accounts and a leaderboard run on a small FastAPI backend.

## Repository layout

```text
game/           Godot project (scenes, scripts, assets, tests)
backend/        FastAPI service: accounts, stats sync, leaderboard
docs/           Specifications
docker/         Container helper scripts (Godot image entrypoint, Android setup)
```

## Status

Working toward MVP1, the first Google Play release: the offline game, a start-level picker, optional accounts with a leaderboard, and a visual redesign. The code for the game, the picker, sync, and the backend is built. The backend is not deployed, the redesign is in progress, and nothing has been validated on a phone yet. Phases and status are in [docs/MVP1_PLAN.md](docs/MVP1_PLAN.md) and the [implementation plan](docs/README_IMPLEMENTATION_PLAN.md). Guest play makes no network calls.

## Docs

- [Project overview](docs/README_PROJECT_OVERVIEW.md): goals, scope, definition of done
- [Architecture](docs/README_ARCHITECTURE.md): structure, responsibilities, state model
- [Gameplay and features](docs/README_GAMEPLAY_FEATURES.md): loop, controls, scoring, persistence
- [Visual design](docs/README_VISUAL_DESIGN.md): theme, colors, layout, sound
- [Implementation plan](docs/README_IMPLEMENTATION_PLAN.md): MVP1 phases and verification checklist
- [Deploying the backend](docs/DEPLOY.md): Neon + Render steps

## Development

Headless Godot runs in Docker via `docker compose`; the backend uses [uv](https://docs.astral.sh/uv/).

```sh
make help          # list targets
make check         # import and parse-check the game
make test          # run game unit tests
make apk           # export game/build/dropgrid-debug.apk
make install       # adb install to a USB-connected phone (brew install --cask android-platform-tools)
make backend-run   # serve the backend at http://localhost:8000 (docs at /docs)
```
