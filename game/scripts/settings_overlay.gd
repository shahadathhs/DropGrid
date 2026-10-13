extends Control

signal closed

@onready var _sound_toggle: CheckButton = %SoundToggle


func _ready() -> void:
	_sound_toggle.button_pressed = Save.sound_enabled
	_sound_toggle.toggled.connect(_on_sound_toggled)


func _on_sound_toggled(enabled: bool) -> void:
	Save.set_sound_enabled(enabled)


func _on_close_pressed() -> void:
	closed.emit()
