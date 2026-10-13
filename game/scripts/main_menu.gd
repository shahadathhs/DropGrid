extends Control

const GAME_SCENE := "res://scenes/game.tscn"

@onready var _best_label: Label = %BestLabel
@onready var _settings_overlay: Control = %SettingsOverlay


func _ready() -> void:
	_best_label.text = "Best %d" % Save.best_score
	_settings_overlay.hide()
	_settings_overlay.closed.connect(func(): _settings_overlay.hide())


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file(GAME_SCENE)


func _on_settings_pressed() -> void:
	_settings_overlay.show()
