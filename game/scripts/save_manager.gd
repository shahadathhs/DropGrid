class_name SaveManager
extends RefCounted
## Loads and saves best score and sound setting under user://.
## A small autoload (Save.gd) wraps this with a single shared instance; see autoload below.

const SAVE_PATH := "user://save.json"
const CURRENT_VERSION := 1

var best_score := 0
var sound_enabled := true


func load_data() -> void:
	best_score = 0
	sound_enabled = true
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_warning("SaveManager: could not open save file: %s" % error_string(FileAccess.get_open_error()))
		return
	var text := file.get_as_text()
	file.close()

	var parsed: Variant = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		push_warning("SaveManager: save file is corrupt; starting fresh.")
		return
	var data: Dictionary = parsed
	best_score = int(data.get("best_score", 0))
	sound_enabled = bool(data.get("sound_enabled", true))


func save_data() -> void:
	var data := {
		"version": CURRENT_VERSION,
		"best_score": best_score,
		"sound_enabled": sound_enabled,
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_warning("SaveManager: could not write save file: %s" % error_string(FileAccess.get_open_error()))
		return
	file.store_string(JSON.stringify(data))
	file.close()


## Updates best_score if score beats it. Returns true if it improved (and saves).
func offer_score(score: int) -> bool:
	if score > best_score:
		best_score = score
		save_data()
		return true
	return false


func set_sound_enabled(enabled: bool) -> void:
	sound_enabled = enabled
	save_data()
