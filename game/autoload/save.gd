extends Node
## Autoload singleton ("Save"): the one shared SaveManager instance for the whole app.
## Registered in Project Settings > Autoload (see project.godot).

var _manager := SaveManager.new()

var best_score: int:
	get: return _manager.best_score
var sound_enabled: bool:
	get: return _manager.sound_enabled
var total_lines: int:
	get: return _manager.total_lines
var games_played: int:
	get: return _manager.games_played
var pending_sync: bool:
	get: return _manager.pending_sync
var stats_revision: int:
	get: return _manager.stats_revision


func _ready() -> void:
	_manager.load_data()


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
