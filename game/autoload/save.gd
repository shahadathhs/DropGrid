extends Node
## Autoload singleton ("Save"): the one shared SaveManager instance for the whole app.
## Registered in Project Settings > Autoload (see project.godot).

var best_score: int:
	get:
		return _manager.best_score
var sound_enabled: bool:
	get:
		return _manager.sound_enabled
var music_enabled: bool:
	get:
		return _manager.music_enabled
var ground_light: bool:
	get:
		return _manager.ground_light
var ghost_enabled: bool:
	get:
		return _manager.ghost_enabled
var left_handed: bool:
	get:
		return _manager.left_handed
var large_buttons: bool:
	get:
		return _manager.large_buttons
var haptics: bool:
	get:
		return _manager.haptics
var total_lines: int:
	get:
		return _manager.total_lines
var games_played: int:
	get:
		return _manager.games_played
var pending_sync: bool:
	get:
		return _manager.pending_sync
var category_bests: Dictionary:
	get:
		return _manager.category_bests
var stats_revision: int:
	get:
		return _manager.stats_revision

var _manager := SaveManager.new()


func _ready() -> void:
	_manager.load_data()
	# The saved ground is applied before any scene builds its theme.
	Palette.apply_ground(_manager.ground_light)


func record_run(score: int, lines_cleared: int) -> bool:
	return _manager.record_run(score, lines_cleared)


func stats() -> Dictionary:
	return _manager.stats()


func apply_merged_stats(merged: Dictionary) -> void:
	_manager.apply_merged_stats(merged)


func mark_synced(revision: int) -> void:
	_manager.mark_synced(revision)


func set_sound_enabled(enabled: bool) -> void:
	_manager.set_sound_enabled(enabled)


func set_haptics(enabled: bool) -> void:
	_manager.set_haptics(enabled)


func set_music_enabled(enabled: bool) -> void:
	_manager.set_music_enabled(enabled)


func set_ground_light(light: bool) -> void:
	_manager.set_ground_light(light)


func set_ghost_enabled(enabled: bool) -> void:
	_manager.set_ghost_enabled(enabled)


func set_left_handed(left: bool) -> void:
	_manager.set_left_handed(left)


func set_large_buttons(large: bool) -> void:
	_manager.set_large_buttons(large)


func record_category_run(category: String, payload: Dictionary) -> bool:
	return _manager.record_category_run(category, payload)


func counting_best(category: String) -> Dictionary:
	return _manager.counting_best(category)


## The category entries Sync sends with the stats (every best except marathon's).
func category_payload() -> Array:
	return _manager.category_payload()
