# Technical Architecture — Godot 4.x

## 1. Architectural approach

Use a small, understandable scene-based architecture. Avoid building a framework for a game this size. The board rules should be testable independently from UI presentation as much as practical.

Use Godot 4.x with GDScript. Confirm the exact Godot version before starting and do not mix Godot 3 APIs with Godot 4 APIs.

The optional account/sync feature adds one FastAPI backend service and a single networking autoload (`Sync`). It must not leak into the gameplay architecture: the game logic and views stay network-free.

## 2. Project structure

The repository is a monorepo: the Godot project lives in `game/` and the FastAPI service in `backend/`.

```text
game/ (res://)
├── project.godot           # autoloads, display, dropgrid/network/api_base_url
├── export_presets.cfg      # Android export (INTERNET, VIBRATE enabled)
├── scenes/
│   ├── main_menu.tscn          # title, Play, Levels entry, account, leaderboard, settings
│   ├── game.tscn               # board, HUD, touch controls, overlays
│   ├── pause_overlay.tscn      # Resume / End run / Menu
│   ├── game_over_overlay.tscn  # final score, best score, Play Again / Levels / Menu
│   ├── settings_overlay.tscn   # sound and haptics toggles
│   ├── levels.tscn             # start-level picker
│   ├── sign_in.tscn            # sign in / register form
│   ├── profile.tscn            # synced stats, rename, sign out, delete account
│   └── leaderboard.tscn        # top 50
├── autoload/
│   ├── save.gd             # "Save": one shared SaveManager
│   ├── sfx.gd              # "Sfx": sound effect playback, honours the sound setting
│   ├── sync.gd             # "Sync": the only networking code (tokens, outbox, HTTP)
│   └── device_preview.gd   # "DevicePreview": desktop debug phone-size simulator
├── scripts/
│   ├── game_config.gd      # all constants: board size, scoring, speeds, start levels, API URL lookup
│   ├── board_model.gd      # logical grid, collision, locking, line clears
│   ├── piece_data.gd       # piece shapes, rotations, colors
│   ├── piece_bag.gd        # shuffled bag piece generator
│   ├── game_controller.gd  # game flow: fall timer, scoring, level rule, pause, game over
│   ├── game.gd             # game scene glue; reads the start level
│   ├── start_level.gd      # hands the chosen start level from the levels screen to the game
│   ├── board_view.gd       # draws the board, ghost, and active piece
│   ├── next_preview.gd     # draws the next piece
│   ├── touch_controls.gd   # buttons to gameplay actions
│   ├── hud_controller.gd   # score, lines, level, best; overlays
│   ├── pause_overlay.gd, game_over_overlay.gd, settings_overlay.gd
│   ├── main_menu.gd, levels_screen.gd, sign_in_screen.gd, profile_screen.gd, leaderboard_screen.gd
│   ├── save_manager.gd     # local stats, settings, sync flag in user://save.json
│   ├── session_store.gd    # tokens and username in user://session.json
│   ├── sync_logic.gd       # pure sync helpers: merge, backoff, input checks, online-enabled check
│   ├── palette.gd          # color tokens
│   ├── game_theme.gd       # builds the shared Theme from the palette
│   ├── brand_mark.gd       # draws the logo mark
│   └── ui_format.gd        # number formatting
├── resources/
│   └── game_theme.tres
├── assets/
│   ├── audio/              # move, rotate, lock, line_clear, game_over (.wav)
│   └── icons/              # SVG icons for buttons
├── tests/                  # GUT unit tests (test_*.gd)
└── addons/                 # vendored GUT test framework

backend/
├── main.py                 # app factory, routers, startup checks
├── core/                   # config, database, db_url, security (jwt, password, deps),
│                           # ratelimit, validation, blocklist, game_limits, exceptions
├── models/                 # SQLAlchemy models (players)
├── modules/
│   ├── auth/               # register, login, refresh
│   ├── players/            # profile, rename, delete
│   ├── scores/             # POST /v1/sync, GET /v1/leaderboard (+ per category and rank)
│   └── web/                # /privacy and /account/delete HTML pages
├── migrations/             # Alembic
├── tests/                  # pytest
└── Dockerfile
```

Other top-level files: `render.yaml` (Render deploy blueprint), `Makefile`, `compose.yaml` (headless Godot and local Postgres), `Dockerfile`, `docker/` (helper scripts), `docs/`, `AGENTS.md` (instructions for AI coding agents).

Do not create empty scripts or scenes just to fill the tree.

## Autoloads

There are four, set in `game/project.godot`:

- `Save`: wraps one `SaveManager` so every screen shares the same local data.
- `Sfx`: plays sound effects. The `SFX` and `Music` audio buses are defined in `game/default_bus_layout.tres` and are never created in code: on the web, a bus added at runtime is mismatched in the browser's audio graph, so muting it silences the master bus and the game makes no sound at all. `tests/test_audio_buses.gd` guards the layout.
- `Sync`: accounts, tokens, outbox, HTTP. The only networking code in the client.
- `DevicePreview`: development tool for desktop debug runs. F9 cycles phone sizes, F10 rotates. It checks for desktop and debug features and does nothing on Android. The check is in code; it has not yet been confirmed on a device.

## Site and the web build

`site/` is a static Next.js marketing site (Vercel). Its `/play` page shows the game's Web export inside a phone frame. The export is built by `make web` (the "Web" preset, headless Godot in Docker; CI job `web`) into `game/build/web/` and published as the `dropgrid-web.tar.gz` asset of the rolling `latest` release. At build time the site's `scripts/fetch-playground.mjs` unpacks it into `site/public/play/game/`; the repo never holds it. The page is a plain server component: an iframe whose inline poster has one Play link, so the game loads only after the visitor presses Play and the site ships no JavaScript for it. When the files are missing at build time the page shows an unavailable state instead. The web build runs as a guest: no storage, no network, keyboard controls. See [DEPLOY.md](DEPLOY.md) and [CI.md](CI.md).

## 3. Responsibilities

### `main_menu.tscn`

- Displays title, best score, Play, the start-level entry, settings, and (only when online features are on) account, leaderboard, and Continue as guest.
- Play starts the game at level 1. The levels entry opens the start-level picker.
- Does not contain board rules.

### `game.tscn`

- Contains the board view, HUD, touch controls, and pause/game-over overlays.
- Connects gameplay events to UI updates.
- Should not duplicate board collision or line-clearing rules.

### `game_controller.gd`

- Owns the game flow and active piece.
- Coordinates piece spawning, fall timer, movement requests, locking, line clears, scoring, levels, pause, and game-over.
- Communicates state changes to the HUD via signals or clear method calls.

### `board_model.gd`

- Owns the logical grid and occupied cells.
- Checks whether a piece placement is valid.
- Locks pieces into the grid.
- Detects and clears completed lines.
- Does not depend on screen coordinates or UI nodes.

### `piece_data.gd` / `piece_bag.gd`

- Represents piece cell offsets, rotation state, and type.
- Keeps shape data separate from visual nodes.
- Use a simple representation that is easy to inspect and debug.

### `board_view.gd`

- Draws the grid, locked cells, ghost preview, and the active piece.
- Converts logical grid positions into screen positions.
- Does not decide whether a move is legal.

### `levels_screen.gd` / `start_level.gd`

- The levels screen lists levels 1 to 10 and locks those above the player's lifetime lines (level N needs 10 × (N − 1)).
- A press stores the choice in `StartLevel` and opens the game. `game.gd` reads it once with `StartLevel.take()`; afterwards it is back to 1.
- `GameController` takes the start level and uses `level_for_run(start, lines_this_game)` = `max(start, lines / 10 + 1)`. Restart reuses the run's start level.

### `touch_controls.gd`

- Converts UI button presses into gameplay actions.
- Does not directly edit board state.
- Optional keyboard input may route through the same action methods.

### `hud_controller.gd`

- Updates score, level, lines, and best score.
- Shows pause and game-over overlays.
- Should not calculate scoring independently.

### `save_manager.gd`

- Loads and saves best score and settings in local user data.
- Handles missing/corrupt data gracefully.

### `sync` autoload

- Owns login state, JWT access/refresh tokens, and all HTTP calls.
- Pushes local stats to `POST /v1/sync` and writes the merged result back to the save.
- Queues and retries requests with backoff; failures never block or break gameplay.
- The only place in the client allowed to use networking.
- Reads the server URL from the project setting `dropgrid/network/api_base_url` (see section 9). An empty URL means online features are off and no request is made.

### `backend/` FastAPI service

- Exposes `/v1` routes for auth, profile, stats sync, and leaderboard, plus two public web pages.
- Owns the server-side merge rule (`max` per stat) and the players table.
- Game rules and scoring stay in the client; the server stores, it does not simulate.

## 4. Communication

Prefer explicit signals or clear method calls over tight coupling and searching the scene tree for nodes at runtime.

Examples of useful events:

- `score_changed(score)`
- `lines_changed(total_lines)`
- `level_changed(level)`
- `piece_locked`
- `lines_cleared(count)`
- `game_over(final_score)`
- `pause_changed(is_paused)`

Autoloads are kept to the four listed above. Do not add another without a concrete reason.

## 5. Data and coordinate rules

- Use integer grid coordinates for all gameplay rules.
- Keep grid coordinates separate from pixel positions.
- Establish one coordinate convention and use it consistently.
- Represent empty cells consistently (for example, `null` or a documented empty value).
- Centralize board dimensions, cell size, fall intervals, scoring, and level thresholds.
- Avoid duplicating magic numbers across scripts.

## 6. Rendering approach

For a small grid, use a straightforward 2D rendering approach. Possible options include a `TileMapLayer`, individual `ColorRect`/`Control` cells, or custom drawing. Pick the approach that best fits a polished responsive UI and the selected Godot version. Do not combine several rendering systems without a clear benefit.

Separate:

- **Model:** board occupancy and rules.
- **Controller:** current game state and transitions.
- **View:** rendering and animation.
- **Input:** touch/keyboard action mapping.

## 7. State management

Use a small explicit state model, for example:

- `MENU`
- `PLAYING`
- `PAUSED`
- `GAME_OVER`

Make transitions intentional. A paused or game-over game must not continue advancing the fall timer or accepting normal movement input.

## 8. Quality rules

- Use typed GDScript where it improves clarity.
- Give variables and functions descriptive names.
- Keep functions small and focused.
- Avoid unnecessary third-party plugins.
- Keep gameplay logic, views, and input free of networking, analytics, and ads. The one sanctioned network client is the `sync` autoload talking to the project's own FastAPI backend.
- Add comments for non-obvious logic, not for every line.
- Handle errors rather than silently ignoring them.
- Do not claim a feature is complete unless it is implemented and tested.

## 9. Sync design (accounts, API, and data)

**Stack:** Python 3.12, FastAPI, Pydantic v2, SQLAlchemy 2, Alembic. PostgreSQL in Docker for local development (`make db-up`), Neon Postgres in production. SQLite (`sqlite+aiosqlite:///./dropgrid.db`) is the default when `DATABASE_URL` is unset and is what the tests use. `core/db_url.py` converts provider URLs for the async driver. Auth via JWT access tokens (~30 min) plus refresh tokens (~30 days); passwords hashed with bcrypt. Backend code and tests live in `backend/` in this repository.

**API (all routes under `/v1`, JSON, proper status codes):**

| Method    | Path                | Auth              | Purpose                                                                               |
| --------- | ------------------- | ----------------- | ------------------------------------------------------------------------------------- |
| POST      | `/v1/auth/register` | —                 | Email + password + username (3–20 chars, blocklist applies) → account + tokens        |
| POST      | `/v1/auth/login`    | —                 | Email + password → tokens                                                             |
| POST      | `/v1/auth/refresh`  | refresh           | New access token                                                                      |
| GET       | `/v1/players/me`    | access            | Profile: username + synced stats                                                      |
| PATCH     | `/v1/players/me`    | access            | Rename (unique, 3–20 chars, blocklist applies)                                        |
| POST      | `/v1/sync`          | access            | Push local stats, server merges, returns merged profile                               |
| GET       | `/v1/leaderboard`   | —                 | Top 50 by best score: rank, username, best_score                                      |
| DELETE    | `/v1/players/me`    | access            | Hard-delete account and data (store compliance)                                       |
| GET       | `/privacy`          | —                 | Privacy policy page (HTML, outside `/v1`)                                             |
| GET, POST | `/account/delete`   | — (form signs in) | Web form: email + password, then hard-delete (Google Play requirement; outside `/v1`) |

**Data model:** one `players` table — `id` (UUID), `email` and `username` (both unique, case-insensitive), `password_hash`, `best_score`, `total_lines`, `games_played`, timestamps. Leaderboard is a query with an index on `best_score`; score history and rating tables come later and are not precluded.

**Merge rule:** the local save stays the source of truth for gameplay. `POST /v1/sync` sends the three local stats and the server stores `max(server_value, client_value)` for each. All three counters are monotonic on the client, so "max" resolves offline play, reinstalls, and multi-device races without conflict handling. The response returns merged state, which the client writes back to its local save. Before merging, the server checks plausibility (`core/game_limits.py`) on the submitted values and answers 422 if `games_played` is 0 while lines or score is above 0, or if `best_score` exceeds what `total_lines` could produce at the maximum level. The limits mirror `game_config.gd` and must be changed in both places.

**Client sync triggers (in the `sync` autoload):** after sign-in or registration; after a game ends; on app background (fire-and-forget); on app start when a refresh token exists. Requests queue in an outbox and retry with exponential backoff; any failure stays invisible to the player.

**Security and privacy:** HTTPS only in production; `password_version` claim so password changes revoke refresh tokens; rate-limited auth endpoints (the web deletion form shares the login bucket); no PII beyond email; score submissions are trusted apart from the plausibility check above (real anti-cheat is out of scope). `ENVIRONMENT=production` makes the app refuse to start with a default or short (under 32 chars) `JWT_SECRET`. `CONTACT_EMAIL` is shown on the privacy page.

**Single instance:** rate limits are held in memory, so run exactly one backend instance. A second one would double the limits and split the counters. See [DEPLOY.md](DEPLOY.md).

**Per-build API URL:** the client reads the project setting `dropgrid/network/api_base_url` in `game/project.godot`. The default points at the local backend for debug and development. A `.release` override applies to release exports; it is empty today, so a release build has online features off until the production HTTPS URL is set there. Release must never point at `http://`. Android exports have the INTERNET and VIBRATE permissions enabled.
