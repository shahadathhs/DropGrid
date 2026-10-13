extends Control
## Settings screen, shown full-screen over the menu or the profile. One row: sound effects.
## The row is a toggle button, so its pressed state is the saved sound setting.

signal closed

## Pixel sizes of the toggle parts (prototype .toggle is 42x25 CSS px, times 1.5).
const TRACK_WIDTH := 63.0
const KNOB_SIZE := 29.0
const KNOB_PAD := 4.0

const VOLUME_ON_ICON := preload("res://assets/icons/volume.svg")
const VOLUME_OFF_ICON := preload("res://assets/icons/volume_off.svg")

@onready var _sound_toggle: Button = %SoundToggle
@onready var _sound_icon: TextureRect = %SoundIcon
@onready var _track: Panel = %ToggleTrack
@onready var _knob: Panel = %ToggleKnob


func _ready() -> void:
	_sound_toggle.button_pressed = Save.sound_enabled
	_sound_toggle.toggled.connect(_on_sound_toggled)
	_refresh_visuals(Save.sound_enabled)


func _on_sound_toggled(enabled: bool) -> void:
	Save.set_sound_enabled(enabled)
	_refresh_visuals(enabled)


## Moves the knob and changes the track color and icon to match the setting.
func _refresh_visuals(enabled: bool) -> void:
	_track.theme_type_variation = &"ToggleOn" if enabled else &"ToggleOff"
	_knob.theme_type_variation = &"ToggleKnobOn" if enabled else &"ToggleKnobOff"
	var knob_x := TRACK_WIDTH - KNOB_SIZE - KNOB_PAD if enabled else KNOB_PAD
	_knob.position = Vector2(knob_x, KNOB_PAD)
	_sound_icon.texture = VOLUME_ON_ICON if enabled else VOLUME_OFF_ICON


func _on_close_pressed() -> void:
	closed.emit()
