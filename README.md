# DropGrid

**A falling-block puzzle for Android.** Portrait, offline first, no ads, no purchases.
Play at [playdropgrid.vercel.app](https://playdropgrid.vercel.app).

DropGrid is a classic stack-and-clear game rebuilt around one idea: the board's cell is
the unit for everything. Graphite for the desk, paper for the sun — two grounds, one
game, seven piece colors that stay readable in grayscale.

## The game

- **Classic rules, honest feel.** 10 × 20 board, 7-bag piece randomizer, wall kicks,
  ghost piece, soft and hard drop. Line points scale with your level.
- **Start at your level.** Ten start levels. The next unlocks at every 10 lifetime
  lines — a threshold, not a grind.
- **Offline first.** The whole game runs with no network. Guest play sends nothing,
  ever.
- **Optional account.** Sign in only if you want to: your best score, total lines, and
  games played sync in the background and appear on a global top-50 leaderboard.
- **No ads. No purchases. No tracking.** Nothing is for sale and nothing nags.

## Get it

- **Versioned releases:** [github.com/shahadathhs/DropGrid/releases/latest](https://github.com/shahadathhs/DropGrid/releases/latest)
  — signed debug APKs from the release pipeline.
- **Rolling dev builds:** [releases/tag/latest](https://github.com/shahadathhs/DropGrid/releases/tag/latest)
  — automatic builds of `main`, refreshed on every push.
- **Google Play:** coming with the first public release.

Install: copy the APK to the phone and open it (allow "install unknown apps" once), or
`adb install -r dropgrid-*.apk`.

## Repository

```text
game/           Godot 4 project (scenes, scripts, assets, tests)
backend/        FastAPI service: accounts, stats sync, leaderboard
site/           Next.js marketing page (this is playdropgrid.vercel.app)
docs/           Specifications
docker/         Container helper scripts (Godot image entrypoint, Android setup)
```

Headless Godot runs in Docker via `docker compose`; the backend uses
[uv](https://docs.astral.sh/uv/); the site uses pnpm.

```sh
make check          # load the game headless; fails on parse/script errors
make test           # run GUT unit tests (game/tests/)
make lint           # GDScript style gate: gdlint + gdformat --check (config: gdlintrc)
make format         # fix GDScript style in place (gdformat)
make apk            # export a debug APK to game/build/
make backend-test   # pytest (run from repo root; cds into backend/)
make backend-lint   # ruff check
make backend-typecheck # pyright
make backend-run    # serve the API at http://localhost:8000 (needs db: make db-up)
make site-dev       # run the marketing site dev server on :3000 (pnpm)
make run            # play the game on this PC (host Godot)
make run-game       # run straight into the game scene
```

After changing game code, run `make lint`, `make check`, and `make test` — formatting is
enforced (`gdformat`), so run `make format` if lint complains. After changing backend
code, run `make backend-lint`, `make backend-typecheck`, and `make backend-test`. After
changing site code, run `make site-lint`, `make site-typecheck`, and `make site-build`.
Docs in `docs/` must match the code; update them in the same change when behavior
changes.

## Releases

Every push to `main` is tested, deploys the backend, and refreshes the rolling
**Latest build**. Versioned releases are cut on purpose:

```sh
make release v=0.2.0   # bumps VERSION, commits, pushes
```

When that lands on `main`, the pipeline publishes **DropGrid v0.2.0** with a signed APK.
See [docs/CI.md](docs/CI.md) for the full pipeline.

## Docs

- [Project overview](docs/README_PROJECT_OVERVIEW.md): goals, scope, definition of done
- [Architecture](docs/README_ARCHITECTURE.md): structure, responsibilities, state model
- [Gameplay and features](docs/README_GAMEPLAY_FEATURES.md): loop, controls, scoring, persistence
- [Visual design](docs/README_VISUAL_DESIGN.md): Cell Unit — theme, colors, layout, sound
- [Implementation plan](docs/README_IMPLEMENTATION_PLAN.md): MVP1 phases and verification checklist
- [Deploying the backend](docs/DEPLOY.md): Neon + Render steps
- [CI, CD and releases](docs/CI.md): the pipeline and how releases are cut

## Contributing

Bug reports and pull requests are welcome — see
[CONTRIBUTING.md](CONTRIBUTING.md) for setup, house rules, and what v1 deliberately
excludes. Security issues go to [SECURITY.md](SECURITY.md), not the issue tracker. By
participating you agree to the [Code of Conduct](CODE_OF_CONDUCT.md).

## License

[MIT](LICENSE)
