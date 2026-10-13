# All Godot work runs in Docker via compose; only `install` needs adb on the host.
GODOT   := docker compose run --rm godot
APK     := build/afterdrop-debug.apk
PRESET  := Android

.DEFAULT_GOAL := help
.PHONY: help import check test apk install run-device shell clean

help: ## Show this help
	@grep -E '^[a-z-]+:.*##' $(MAKEFILE_LIST) | awk -F':.*## ' '{printf "  %-12s %s\n", $$1, $$2}'

import: ## Import assets and build the .godot cache
	$(GODOT) godot --headless --path . --import

check: import ## Load the project headless; fails on script parse errors
	$(GODOT) godot --headless --path . --quit

test: ## Run unit tests (GUT, tests/ dir; add addons/gut first)
	$(GODOT) godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -gexit

apk: import ## Export a debug APK to build/
	@mkdir -p build
	$(GODOT) bash -c 'android-setup && godot --headless --path . --export-debug "$(PRESET)" $(APK)'
	@echo "Built $(APK)"

install: ## Install the APK on a USB-connected phone (needs adb on the host)
	adb install -r $(APK)

run-device: install ## Install and launch on the phone
	adb shell monkey -p $$(grep -m1 'package/unique_name' export_presets.cfg | cut -d'"' -f2) 1

shell: ## Open a shell in the Godot container
	$(GODOT) bash

clean: ## Remove build output and the Godot cache
	rm -rf build .godot
