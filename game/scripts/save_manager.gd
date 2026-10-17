class_name SaveManager
extends RefCounted
## Loads and saves local stats, the sync flag, and the sound and haptics settings under user://.
## A small autoload (Save.gd) wraps this with a single shared instance; see autoload below.

const SAVE_PATH := "user://save.json"
## Version 3 added per-mode settings (music, ground, ghost, left-handed, large
## buttons) and per-category bests. Versions 1 and 2 still load with defaults.
const CURRENT_VERSION := 3

## Score categories (see GameMode): marathon, sprint, ultra, daily. Zen keeps no best.
const SCORE_CATEGORIES: Array[String] = ["marathon", "sprint", "ultra", "daily"]

## Where this instance reads and writes. Tests point it at a temp file.
var save_path := SAVE_PATH
## When false nothing is read from or written to disk; everything lives in memory
## for the session. The web build turns this off (user:// would be browser storage).
var persist := not GameConfig.is_web()

var best_score := 0
var sound_enabled := true
var music_enabled := false  # off by default: the loops are there if you want them
var ground_light := false
var ghost_enabled := true
var left_handed := false
var large_buttons := false
var haptics := true
var total_lines := 0
var games_played := 0
## Per category bests, e.g. category_bests["marathon"] = {"score": 120, "lines": 4}.
## Sprint stores duration_ms instead of a score (lower is better); daily adds
## the UTC "date" the best was set on.
var category_bests := {}
## True when local stats changed since the last successful sync.
var pending_sync := false
## Goes up on every recorded run (not saved). A sync remembers the revision it sent,
## so a run recorded while that request was in flight stays pending.
var stats_revision := 0


func load_data() -> void:
	apply_data({})
	if not persist:
		return
	if not FileAccess.file_exists(save_path):
		return
	var file := FileAccess.open(save_path, FileAccess.READ)
	if file == null:
		push_warning(
			"SaveManager: could not open save file: %s" % error_string(FileAccess.get_open_error())
		)
		return
	var text := file.get_as_text()
	file.close()

	# JSON.new().parse reports bad text through its return code, without an engine error.
	var json := JSON.new()
	if json.parse(text) != OK or typeof(json.data) != TYPE_DICTIONARY:
		push_warning("SaveManager: save file is corrupt; starting fresh.")
		return
	apply_data(json.data)


## Copies values from parsed save data. Any missing field falls back to its default,
## so an old version 1 file (no stats fields) loads with zeros.
func apply_data(data: Dictionary) -> void:
	best_score = int(data.get("best_score", 0))
	sound_enabled = bool(data.get("sound_enabled", true))
	music_enabled = bool(data.get("music_enabled", false))
	ground_light = bool(data.get("ground_light", false))
	ghost_enabled = bool(data.get("ghost_enabled", true))
	left_handed = bool(data.get("left_handed", false))
	large_buttons = bool(data.get("large_buttons", false))
	haptics = bool(data.get("haptics", true))
	category_bests = {}
	var stored_bests: Variant = data.get("category_bests", {})
	if typeof(stored_bests) == TYPE_DICTIONARY:
		for key in stored_bests:
			if key in SCORE_CATEGORIES and typeof(stored_bests[key]) == TYPE_DICTIONARY:
				category_bests[key] = stored_bests[key]
	total_lines = int(data.get("total_lines", 0))
	games_played = int(data.get("games_played", 0))
	pending_sync = bool(data.get("pending_sync", false))


func to_dictionary() -> Dictionary:
	return {
		"version": CURRENT_VERSION,
		"best_score": best_score,
		"sound_enabled": sound_enabled,
		"music_enabled": music_enabled,
		"ground_light": ground_light,
		"ghost_enabled": ghost_enabled,
		"left_handed": left_handed,
		"large_buttons": large_buttons,
		"haptics": haptics,
		"total_lines": total_lines,
		"games_played": games_played,
		"pending_sync": pending_sync,
		"category_bests": category_bests,
	}


func save_data() -> void:
	if not persist:
		return
	var file := FileAccess.open(save_path, FileAccess.WRITE)
	if file == null:
		push_warning(
			"SaveManager: could not write save file: %s" % error_string(FileAccess.get_open_error())
		)
		return
	file.store_string(JSON.stringify(to_dictionary()))
	file.close()


## Records a finished game: counts it, adds its cleared lines, raises the best score
## if it was beaten, and marks the stats as needing a sync. Returns true if the best improved.
func record_run(score: int, lines_cleared: int) -> bool:
	var improved := score > best_score
	if improved:
		best_score = score
	games_played += 1
	total_lines += lines_cleared
	pending_sync = true
	stats_revision += 1
	save_data()
	return improved


func stats() -> Dictionary:
	return {
		"best_score": best_score,
		"total_lines": total_lines,
		"games_played": games_played,
		"category_bests": category_bests,
	}


## The sync payload's category entries: every best except marathon, whose best
## travels as best_score on the player row.
func category_payload() -> Array:
	var entries: Array = []
	for category in SCORE_CATEGORIES:
		if category == "marathon":
			continue
		var best: Dictionary = counting_best(category)
		if best.is_empty():
			continue
		var entry := best.duplicate()
		entry["category"] = category
		entries.append(entry)
	return entries


## Writes merged stats (see SyncLogic.merge_stats) back into the save.
func apply_merged_stats(merged: Dictionary) -> void:
	best_score = int(merged.get("best_score", best_score))
	total_lines = int(merged.get("total_lines", total_lines))
	games_played = int(merged.get("games_played", games_played))
	if merged.has("category_bests"):
		category_bests = {}
		var server_bests: Variant = merged.get("category_bests", {})
		if typeof(server_bests) == TYPE_DICTIONARY:
			for key in server_bests:
				if key in SCORE_CATEGORIES and typeof(server_bests[key]) == TYPE_DICTIONARY:
					category_bests[key] = server_bests[key]
	save_data()


## Clears pending_sync only if no new run was recorded after the sync was sent.
func mark_synced(revision: int) -> void:
	if revision == stats_revision:
		pending_sync = false
		save_data()


func set_sound_enabled(enabled: bool) -> void:
	sound_enabled = enabled
	save_data()


func set_haptics(enabled: bool) -> void:
	haptics = enabled
	save_data()


func set_music_enabled(enabled: bool) -> void:
	music_enabled = enabled
	save_data()


func set_ground_light(light: bool) -> void:
	ground_light = light
	save_data()


func set_ghost_enabled(enabled: bool) -> void:
	ghost_enabled = enabled
	save_data()


func set_left_handed(left: bool) -> void:
	left_handed = left
	save_data()


func set_large_buttons(large: bool) -> void:
	large_buttons = large
	save_data()


## Records a category best. Score categories compare score (higher wins);
## sprint compares duration_ms (lower wins); daily only competes within its
## UTC date. Returns true when the local best improved.
func record_category_run(category: String, payload: Dictionary) -> bool:
	if not category in SCORE_CATEGORIES:
		return false
	var current: Dictionary = category_bests.get(category, {})
	if category == "daily":
		var today: String = GameMode.daily_date()
		if str(current.get("date", "")) != today:
			current = {}
		payload["date"] = today
	var improved := false
	if category == "sprint":
		var duration := int(payload.get("duration_ms", 0))
		if duration <= 0 or current.is_empty() or duration < int(current.get("duration_ms", 0)):
			improved = true
	else:
		var score := int(payload.get("score", 0))
		if current.is_empty() or score > int(current.get("score", 0)):
			improved = true
	if improved:
		category_bests[category] = payload
		save_data()
	return improved


## The best that still counts today (an expired daily best returns empty).
func counting_best(category: String) -> Dictionary:
	var best: Dictionary = category_bests.get(category, {})
	if category == "daily" and str(best.get("date", "")) != GameMode.daily_date():
		return {}
	return best
