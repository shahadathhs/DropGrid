extends Control
## Settings screen, shown full-screen over the menu. Two rows: sound and haptics.
## Each row is a toggle button, so its pressed state is the saved setting.

signal closed

@onready var _sound_toggle: Button = %SoundToggle
@onready var _sound_switch: ToggleSwitch = %SoundSwitch
@onready var _haptics_toggle: Button = %HapticsToggle
@onready var _haptics_switch: ToggleSwitch = %HapticsSwitch


func _ready() -> void:
	_sound_toggle.button_pressed = Save.sound_enabled
	_sound_toggle.toggled.connect(_on_sound_toggled)
	_sound_switch.on = Save.sound_enabled
	_haptics_toggle.button_pressed = Save.haptics
	_haptics_toggle.toggled.connect(_on_haptics_toggled)
	_haptics_switch.on = Save.haptics


func _on_sound_toggled(enabled: bool) -> void:
	Save.set_sound_enabled(enabled)
	_sound_switch.on = enabled


func _on_haptics_toggled(enabled: bool) -> void:
	Save.set_haptics(enabled)
	_haptics_switch.on = enabled


func _on_close_pressed() -> void:
	closed.emit()
