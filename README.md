# After Drop

A polished, lightweight 2D falling-block puzzle game for Android, built with **Godot 4.x** and **GDScript**. Portrait, offline-first, no ads, accounts, or backend.

> Working title: Dropgrid (temporary).

## Status

Planning. The specification lives in [docs/](docs/); no game code yet.

## Docs

- [Project overview](docs/README_PROJECT_OVERVIEW.md): goals, scope, definition of done
- [Architecture](docs/README_ARCHITECTURE.md): structure, responsibilities, state model
- [Gameplay and features](docs/README_GAMEPLAY_FEATURES.md): loop, controls, scoring, persistence
- [Visual design](docs/README_VISUAL_DESIGN.md): theme, colors, layout, sound
- [Implementation plan](docs/README_IMPLEMENTATION_PLAN.md): build phases and verification checklist

## Development (Docker, no local Godot)

Godot runs headless in a container via `docker compose`; the image is pulled automatically on first use.

```sh
make help      # list targets
make check     # import and parse-check the project
make test      # run unit tests
make apk       # export build/afterdrop-debug.apk
make install   # adb install to a USB-connected phone (brew install --cask android-platform-tools)
```
