class_name SaveManager
extends RefCounted
## Loads and saves local stats, the sync flag, and the sound setting under user://.
## A small autoload (Save.gd) wraps this with a single shared instance; see autoload below.

const SAVE_PATH := "user://save.json"
## Version 2 added total_lines, games_played, and pending_sync. Version 1 files still load.
const CURRENT_VERSION := 2

## Where this instance reads and writes. Tests point it at a temp file.
var save_path := SAVE_PATH

var best_score := 0
var sound_enabled := true
var total_lines := 0
var games_played := 0
## True when local stats changed since the last successful sync.
var pending_sync := false
## Goes up on every recorded run (not saved). A sync remembers the revision it sent,
## so a run recorded while that request was in flight stays pending.
var stats_revision := 0


func load_data() -> void:
	apply_data({})
	if not FileAccess.file_exists(save_path):
		return
	var file := FileAccess.open(save_path, FileAccess.READ)
	if file == null:
		push_warning("SaveManager: could not open save file: %s" % error_string(FileAccess.get_open_error()))
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
	total_lines = int(data.get("total_lines", 0))
	games_played = int(data.get("games_played", 0))
	pending_sync = bool(data.get("pending_sync", false))


func to_dictionary() -> Dictionary:
	return {
		"version": CURRENT_VERSION,
		"best_score": best_score,
		"sound_enabled": sound_enabled,
		"total_lines": total_lines,
		"games_played": games_played,
		"pending_sync": pending_sync,
	}


func save_data() -> void:
	var file := FileAccess.open(save_path, FileAccess.WRITE)
	if file == null:
		push_warning("SaveManager: could not write save file: %s" % error_string(FileAccess.get_open_error()))
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
	}


## Writes merged stats (see SyncLogic.merge_stats) back into the save.
func apply_merged_stats(merged: Dictionary) -> void:
	best_score = int(merged.get("best_score", best_score))
	total_lines = int(merged.get("total_lines", total_lines))
	games_played = int(merged.get("games_played", games_played))
	save_data()


## Clears pending_sync only if no new run was recorded after the sync was sent.
func mark_synced(revision: int) -> void:
	if revision == stats_revision:
		pending_sync = false
		save_data()


func set_sound_enabled(enabled: bool) -> void:
	sound_enabled = enabled
	save_data()
