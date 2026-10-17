# Contributing to DropGrid

Thanks for wanting to help. DropGrid is a portrait falling-block puzzle game for Android (Godot 4 + GDScript) with an optional FastAPI backend. Read [docs/README_PROJECT_OVERVIEW.md](docs/README_PROJECT_OVERVIEW.md) first: it defines what v1 includes and, just as important, what it does not.

## Setup

You need Docker (headless Godot runs inside it) and [uv](https://docs.astral.sh/uv/). Then:

```sh
make setup      # one-time: tools check, local Postgres, backend deps, migrations
make test       # game unit tests (GUT, in Docker)
make backend-test
```

Play the game on your computer with `make run`; work on the backend API with `make backend-run` (interactive docs at http://localhost:8000/docs).

## Before you open a PR

Run the checks that cover your change:

| Changed | Run |
|---|---|
| `game/` | `make lint` (style is enforced), `make check`, `make test` |
| `backend/` | `make backend-lint`, `make backend-typecheck`, `make backend-test` |
| anything | keep `docs/` matching the code |

CI runs the same commands; a PR that fails them will not be reviewed in detail.

## House rules

- **Do not change gameplay for visual reasons.** Rules, scoring, and controls follow [docs/README_GAMEPLAY_FEATURES.md](docs/README_GAMEPLAY_FEATURES.md).
- **Do not add features from the overview's "not included" list.** Propose first in an issue if you think something belongs there.
- **Follow the architecture** in [docs/README_ARCHITECTURE.md](docs/README_ARCHITECTURE.md): pure-logic model/controller with signals, views only in scenes; all colors in `game/scripts/palette.gd`, all styles in `game/scripts/game_theme.gd`; tuning constants in `game/scripts/game_config.gd`; network code only in the `Sync` autoload. Guest play makes zero network calls.
- **Visual changes follow the design system** ("Cell Unit", see [docs/README_VISUAL_DESIGN.md](docs/README_VISUAL_DESIGN.md)). If you touch UI, capture screenshots with `DevicePreview` (see AGENTS.md) at 390×844, 360×640, and 412×915 and attach them to the PR.
- **Backend limits mirror game limits**: `backend/core/game_limits.py` and `game/scripts/game_config.gd` must stay consistent; the production service is a single instance (in-process rate limiter).
- **Never claim you ran Godot, exported an APK, or tested on a phone unless you actually did.** Say what you verified and how.

## Commits and PRs

- Commit messages: short imperative summary, no prefix conventions ("Add HTTPS redirect", not "feat: ...").
- One logical change per PR. Keep it reviewable.
- Describe how you tested the change. If you could not test something, say so plainly.

## Reporting issues

Use the issue templates (bug report or feature request). For security problems, do not open a public issue — see [SECURITY.md](SECURITY.md). Everyone is expected to follow the [Code of Conduct](CODE_OF_CONDUCT.md).
