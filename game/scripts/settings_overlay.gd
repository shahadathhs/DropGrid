extends Control
## Settings screen, shown full-screen over the menu or the profile. Two rows: sound effects
## and haptics. Each row is a toggle button, so its pressed state is the saved setting.

signal closed

## Pixel sizes of the toggle parts (prototype .toggle is 42x25 CSS px, times 1.5).
const TRACK_WIDTH := 63.0
const KNOB_SIZE := 29.0
const KNOB_PAD := 4.0

const VOLUME_ON_ICON := preload("res://assets/icons/volume.svg")
const VOLUME_OFF_ICON := preload("res://assets/icons/volume_off.svg")

@onready var _sound_toggle: Button = %SoundToggle
@onready var _sound_icon: TextureRect = %SoundIcon
@onready var _sound_track: Panel = %ToggleTrack
@onready var _sound_knob: Panel = %ToggleKnob
@onready var _haptics_toggle: Button = %HapticsToggle
@onready var _haptics_track: Panel = %HapticsTrack
@onready var _haptics_knob: Panel = %HapticsKnob


func _ready() -> void:
	_sound_toggle.button_pressed = Save.sound_enabled
	_sound_toggle.toggled.connect(_on_sound_toggled)
	_refresh_sound(Save.sound_enabled)
	_haptics_toggle.button_pressed = Save.haptics
	_haptics_toggle.toggled.connect(_on_haptics_toggled)
	_refresh_toggle(_haptics_track, _haptics_knob, Save.haptics)


func _on_sound_toggled(enabled: bool) -> void:
	Save.set_sound_enabled(enabled)
	_refresh_sound(enabled)


func _on_haptics_toggled(enabled: bool) -> void:
	Save.set_haptics(enabled)
	_refresh_toggle(_haptics_track, _haptics_knob, enabled)


func _refresh_sound(enabled: bool) -> void:
	_refresh_toggle(_sound_track, _sound_knob, enabled)
	_sound_icon.texture = VOLUME_ON_ICON if enabled else VOLUME_OFF_ICON


## Moves the knob and changes the track color to match the setting.
func _refresh_toggle(track: Panel, knob: Panel, enabled: bool) -> void:
	track.theme_type_variation = &"ToggleOn" if enabled else &"ToggleOff"
	knob.theme_type_variation = &"ToggleKnobOn" if enabled else &"ToggleKnobOff"
	var knob_x := TRACK_WIDTH - KNOB_SIZE - KNOB_PAD if enabled else KNOB_PAD
	knob.position = Vector2(knob_x, KNOB_PAD)


func _on_close_pressed() -> void:
	closed.emit()
