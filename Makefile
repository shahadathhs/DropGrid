# Monorepo: game/ (Godot), backend/ (FastAPI), ui-prototype/ (Next.js reference).
# Headless Godot work runs in Docker; backend uses uv; UI uses pnpm.
GODOT   := docker compose run --rm godot
APK     := game/build/dropgrid-debug.apk
PRESET  := Android
UI      := ui-prototype
BACKEND := backend

.DEFAULT_GOAL := help
.PHONY: help setup check-tools backend-env godot-install db-up db-down import check test apk install run-device run run-game \
        backend-install backend-run backend-test backend-lint backend-migrate \
        ui-install ui-dev ui-build shell clean

help: ## Show this help
	@grep -E '^[a-z-]+:.*##' $(MAKEFILE_LIST) | awk -F':.*## ' '{printf "  %-16s %s\n", $$1, $$2}'

# ── Game: headless (Docker) ───────────────────────────────────────────

import: ## Import assets and build the .godot cache
	$(GODOT) godot --headless --path . --import

check: import ## Load the project headless (autoloads + main scene); fails on errors
	$(GODOT) godot --headless --path . --quit-after 1

test: ## Run game unit tests (GUT, game/tests/)
	$(GODOT) godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -gexit

apk: import ## Export a debug APK to game/build/
	@mkdir -p game/build
	$(GODOT) bash -c 'android-setup && godot --headless --path . --export-debug "$(PRESET)" build/dropgrid-debug.apk'
	@echo "Built $(APK)"

# ── Game: on this PC / phone ──────────────────────────────────────────

run: ## Play the game on this PC (needs godot: brew install --cask godot)
	godot --path game

run-game: ## Run straight into the game scene, for debugging gameplay
	godot --path game res://scenes/game.tscn

install: ## Install the APK on a USB-connected phone (needs adb on the host)
	adb install -r $(APK)

run-device: install ## Install and launch on the phone
	adb shell monkey -p $$(grep -m1 'package/unique_name' game/export_presets.cfg | cut -d'"' -f2) 1

# ── Backend (uv, backend/) ────────────────────────────────────────────

setup: check-tools backend-env db-up backend-install backend-migrate ui-install godot-install ## One-time local setup: tools, database, backend, UI prototype, Godot
	@echo ""
	@echo "Setup complete. Start the pieces you need:"
	@echo "  make backend-run   API at http://localhost:8000 (docs at /docs)"
	@echo "  make ui-dev        prototype at http://localhost:3000"
	@echo "  make run           the game on this Mac"

check-tools: ## Verify docker, uv, and pnpm are installed and Docker is running
	@command -v docker >/dev/null || { echo "Missing: docker. Install Docker Desktop: https://www.docker.com/products/docker-desktop"; exit 1; }
	@docker info >/dev/null 2>&1 || { echo "Docker is installed but not running. Start Docker Desktop, then run make setup again."; exit 1; }
	@command -v uv >/dev/null || { echo "Missing: uv. Install with: brew install uv"; exit 1; }
	@command -v pnpm >/dev/null || { echo "Missing: pnpm. Install with: brew install pnpm (or: corepack enable)"; exit 1; }
	@echo "Tools OK: docker (running), uv, pnpm"

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

backend-install: ## Install backend dependencies (uv)
	cd $(BACKEND) && uv sync

backend-run: backend-migrate ## Migrate the dev database, then serve at http://localhost:8000 (uvicorn --reload)
	cd $(BACKEND) && uv run uvicorn main:app --reload --port 8000

backend-migrate: ## Apply database migrations to DATABASE_URL (alembic upgrade head)
	cd $(BACKEND) && uv run alembic upgrade head

backend-test: ## Run backend tests (pytest)
	cd $(BACKEND) && uv run pytest

backend-lint: ## Lint backend (ruff)
	cd $(BACKEND) && uv run ruff check .

# ── UI prototype (pnpm, ui-prototype/) ────────────────────────────────

ui-install: ## Install UI prototype dependencies (pnpm)
	cd $(UI) && pnpm install

ui-dev: ## Serve the UI prototype at http://localhost:3000
	cd $(UI) && pnpm dev

ui-build: ## Production-build the UI prototype
	cd $(UI) && pnpm build

# ── Misc ──────────────────────────────────────────────────────────────

shell: ## Open a shell in the Godot container
	$(GODOT) bash

clean: ## Remove build output, the Godot cache, and backend env/caches
	rm -rf game/build game/.godot $(BACKEND)/.venv $(BACKEND)/.pytest_cache $(BACKEND)/.ruff_cache
