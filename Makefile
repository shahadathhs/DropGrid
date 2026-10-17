# Monorepo: game/ (Godot), backend/ (FastAPI).
# Headless Godot work runs in Docker; backend uses uv.
GODOT   := docker compose run --rm godot
APK     := game/build/dropgrid-debug.apk
PRESET  := Android
BACKEND := backend
# Pinned GDScript tooling, run from the host via uv (no Docker needed).
GDTOOLKIT := gdtoolkit==4.5.0
GDLINT    := uvx --from $(GDTOOLKIT) gdlint
GDFORMAT  := uvx --from $(GDTOOLKIT) gdformat

shot-size ?= 390x844
shot-out  ?= /tmp/dropgrid-shot.png

.DEFAULT_GOAL := help
.PHONY: help android-key setup check-tools backend-env godot-install db-up db-down import check test apk web web-serve install run-device run run-game lint format shot \
        backend-install backend-run backend-test backend-lint backend-typecheck backend-format backend-migrate backend-migration \
        site-install site-dev site-play site-build site-lint site-typecheck \
        shell clean

help: ## Show this help
	@grep -E '^[a-z-]+:.*##' $(MAKEFILE_LIST) | awk -F':.*## ' '{printf "  %-16s %s\n", $$1, $$2}'

# ── Game: headless (Docker) ───────────────────────────────────────────

import: ## Import assets and build the .godot cache
	$(GODOT) godot --headless --path . --import

check: import ## Load the project headless (autoloads + main scene); fails on errors
	$(GODOT) godot --headless --path . --quit-after 1

test: ## Run game unit tests (GUT, game/tests/)
	$(GODOT) godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -gexit

lint: ## Check GDScript style: gdlint + gdformat --check (config: gdlintrc)
	$(GDLINT) game/scripts game/autoload game/tests
	$(GDFORMAT) --check game/scripts game/autoload game/tests

format: ## Fix GDScript style in place (gdformat, then gdlint still applies)
	$(GDFORMAT) game/scripts game/autoload game/tests

apk: import ## Export a debug APK to game/build/
	@mkdir -p game/build
	$(GODOT) bash -c 'android-setup && godot --headless --path . --export-debug "$(PRESET)" build/dropgrid-debug.apk'
	@echo "Built $(APK)"

web: import ## Export the browser build to game/build/web/
	@mkdir -p game/build/web
	$(GODOT) bash -c 'godot --headless --path . --export-release "Web" build/web/index.html'
	@echo "Built game/build/web/"

web-serve: ## Serve game/build/web at http://localhost:8080
	python3 -m http.server 8080 --directory game/build/web

android-key: ## Print a new debug signing key as base64 (the CI secret; see docs/CI.md)
	@$(GODOT) bash -c 'keytool -genkeypair -keyalg RSA -alias androiddebugkey -keypass android -keystore /tmp/k.ks -storepass android -dname "CN=DropGrid Debug" -validity 9999 -deststoretype pkcs12 >/dev/null 2>&1 && base64 -w0 /tmp/k.ks' 2>/dev/null | tail -1

# ── Game: on this PC / phone ──────────────────────────────────────────

run: ## Play the game on this PC (needs godot: brew install --cask godot)
	godot --path game

run-game: ## Run straight into the game scene, for debugging gameplay
	godot --path game res://scenes/game.tscn

shot: ## Screenshot the game via DevicePreview: make shot [size=390x844] [out=/tmp/dropgrid-shot.png]
	godot --path game -- --shot=$(shot-out) --size=$(shot-size) --demo

install: ## Install the APK on a USB-connected phone (needs adb on the host)
	adb install -r $(APK)

run-device: install ## Install and launch on the phone
	adb shell monkey -p $$(grep -m1 'package/unique_name' game/export_presets.cfg | cut -d'"' -f2) 1

# ── Backend (uv, backend/) ────────────────────────────────────────────

setup: check-tools backend-env db-up backend-install backend-migrate godot-install import ## One-time local setup: tools, database, backend, Godot
	@echo ""
	@echo "Setup complete. Start the pieces you need:"
	@echo "  make backend-run   API at http://localhost:8000 (docs at /docs)"
	@echo "  make run           the game on this Mac"

check-tools: ## Verify docker, uv, and Godot are installed and Docker is running
	@command -v docker >/dev/null || { echo "Missing: docker. Install Docker Desktop: https://www.docker.com/products/docker-desktop"; exit 1; }
	@docker info >/dev/null 2>&1 || { echo "Docker is installed but not running. Start Docker Desktop, then run make setup again."; exit 1; }
	@command -v uv >/dev/null || { echo "Missing: uv. Install with: brew install uv"; exit 1; }
	@echo "Tools OK: docker (running), uv"

backend-env: ## Create backend/.env for local Postgres if it does not exist (never overwrites)
	@if [ -f $(BACKEND)/.env ]; then \
		echo "$(BACKEND)/.env already exists, keeping it"; \
	else \
		{ grep -v '^JWT_SECRET=' $(BACKEND)/.env.example; echo "JWT_SECRET=$$(openssl rand -hex 32)"; } > $(BACKEND)/.env; \
		echo "Created $(BACKEND)/.env for local Postgres. For Neon, replace DATABASE_URL in it."; \
	fi

db-up: ## Start local Postgres in Docker and wait until it accepts connections
	docker compose up -d --wait db

db-down: ## Stop local Postgres (data is kept in the pgdata volume)
	docker compose stop db

godot-install: ## Install Godot 4.7 with Homebrew if it is not already installed (macOS)
	@if command -v godot >/dev/null 2>&1; then \
		echo "Godot already installed: $$(godot --version)"; \
	else \
		command -v brew >/dev/null || { echo "Homebrew is needed to install Godot: https://brew.sh"; exit 1; }; \
		brew install --cask godot; \
	fi

backend-install: ## Install backend dependencies (uv), recreating a stale .venv (e.g. after moving/copying the repo)
	@cd $(BACKEND) && if [ -d .venv ] && ! uv run --no-sync uvicorn --version >/dev/null 2>&1; then \
		echo "backend/.venv is stale or broken, recreating it"; \
		rm -rf .venv; \
	fi
	cd $(BACKEND) && uv sync

backend-run: backend-migrate ## Migrate the dev database, then serve at http://localhost:8000 (uvicorn --reload)
	cd $(BACKEND) && uv run uvicorn main:app --reload --port 8000

backend-migrate: ## Apply database migrations to DATABASE_URL (alembic upgrade head)
	cd $(BACKEND) && uv run alembic upgrade head

backend-test: ## Run backend tests (pytest)
	cd $(BACKEND) && uv run pytest

backend-lint: ## Lint backend (ruff)
	cd $(BACKEND) && uv run ruff check .

backend-format: ## Format backend (ruff format + autofix)
	cd $(BACKEND) && uv run ruff format .
	cd $(BACKEND) && uv run ruff check --fix .

backend-typecheck: ## Type-check backend (pyright)
	cd $(BACKEND) && uv run pyright

backend-migration: ## Generate a migration: make backend-migration m="add x"
	@test -n "$(m)" || { echo 'Usage: make backend-migration m="message"'; exit 1; }
	cd $(BACKEND) && uv run alembic upgrade head
	cd $(BACKEND) && uv run alembic revision --autogenerate -m "$(m)"
	@echo "If upgrade()/downgrade() are just 'pass', there were no model changes - delete the file."

# ── Site (Next.js marketing page, Vercel) ─────────────────────────────

site-install: ## Install site dependencies (pnpm)
	cd site && pnpm install

site-dev: ## Run the site dev server on :3000
	cd site && pnpm dev

site-play: web ## Build the browser game and put it in the site, so /play works locally
	rm -rf site/public/play/game
	mkdir -p site/public/play/game
	rsync -a --exclude='*.import' game/build/web/ site/public/play/game/
	@echo "Game copied to site/public/play/game. Run make site-dev and open /play."

site-build: ## Build the site (next build)
	cd site && pnpm build

site-lint: ## Lint the site (oxlint + eslint + prettier)
	cd site && pnpm lint

site-typecheck: ## Type-check the site (tsc)
	cd site && pnpm typecheck

release: ## Cut a versioned release: make release v=0.2.0 (bumps VERSION, commits, pushes)
	@./scripts/bump-version.sh v=$(v)

# ── Misc ──────────────────────────────────────────────────────────────

shell: ## Open a shell in the Godot container
	$(GODOT) bash

clean: ## Remove build output, the Godot cache, and backend env/caches
	rm -rf game/build game/.godot $(BACKEND)/.venv $(BACKEND)/.pytest_cache $(BACKEND)/.ruff_cache
