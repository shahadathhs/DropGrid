extends Node
## Autoload singleton ("Save"): the one shared SaveManager instance for the whole app.
## Registered in Project Settings > Autoload (see project.godot).

var _manager := SaveManager.new()

var best_score: int:
	get: return _manager.best_score
var sound_enabled: bool:
	get: return _manager.sound_enabled


func _ready() -> void:
	_manager.load_data()


func offer_score(score: int) -> bool:
	return _manager.offer_score(score)


func set_sound_enabled(enabled: bool) -> void:
	_manager.set_sound_enabled(enabled)
