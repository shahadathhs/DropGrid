# DropGrid

A polished, lightweight 2D falling-block puzzle game built with **Godot 4.x** and **GDScript**. Portrait, offline-first, no ads or purchases. Optional accounts and a leaderboard run on a small FastAPI backend.

**Download the newest test build:** [latest APK](https://github.com/shahadathhs/DropGrid/releases/latest) · [CI/CD status](https://github.com/shahadathhs/DropGrid/actions/workflows/ci.yml)

## Repository layout

```text
game/           Godot project (scenes, scripts, assets, tests)
backend/        FastAPI service: accounts, stats sync, leaderboard
site/           Next.js marketing page (deployed on Vercel)
docs/           Specifications
docker/         Container helper scripts (Godot image entrypoint, Android setup)
```

## Status

Working toward MVP1, the first Google Play release: the offline game, a start-level picker, optional accounts with a leaderboard, and a visual redesign. The code for the game, the picker, sync, the backend, and the visual redesign is built. The backend is not deployed, and nothing has been validated on a phone yet. Phases and status are in the [implementation plan](docs/README_IMPLEMENTATION_PLAN.md). Guest play makes no network calls.

## Docs

- [Project overview](docs/README_PROJECT_OVERVIEW.md): goals, scope, definition of done
- [Architecture](docs/README_ARCHITECTURE.md): structure, responsibilities, state model
- [Gameplay and features](docs/README_GAMEPLAY_FEATURES.md): loop, controls, scoring, persistence
- [Visual design](docs/README_VISUAL_DESIGN.md): theme, colors, layout, sound
- [Implementation plan](docs/README_IMPLEMENTATION_PLAN.md): MVP1 phases and verification checklist
- [Deploying the backend](docs/DEPLOY.md): Neon + Render steps
- [CI and APK builds](docs/CI.md): tests, and a downloadable APK from every push

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

## Contributing

Bug reports and pull requests are welcome — see [CONTRIBUTING.md](CONTRIBUTING.md) for setup, house rules, and what v1 deliberately excludes. Security issues go to [SECURITY.md](SECURITY.md), not the issue tracker. By participating you agree to the [Code of Conduct](CODE_OF_CONDUCT.md).

Every push to `main` is tested by CI, then CD deploys the backend, builds an APK, and refreshes the [latest pre-release](https://github.com/shahadathhs/DropGrid/releases/tag/latest); version tags become official releases. See [docs/CI.md](docs/CI.md).

## License

[MIT](LICENSE)
