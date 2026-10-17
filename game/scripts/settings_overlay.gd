extends Control
## Settings screen, shown full-screen over the menu. Rows are built in code from
## one declarative list: every row is a label, an optional hint, and a switch
## backed by a Save setting.

signal closed

const GROUND_HINT := "Applies next launch."

var _switches := {}

@onready var _list: VBoxContainer = %List


func _ready() -> void:
	_add_row(
		"Sound",
		"Effects and stings",
		func(enabled: bool) -> void:
			Save.set_sound_enabled(enabled)
			Sfx.update_buses(),
		Save.sound_enabled
	)
	_add_row(
		"Music",
		"The background loops",
		func(enabled: bool) -> void:
			Save.set_music_enabled(enabled)
			Music.update_buses(),
		Save.music_enabled
	)
	_add_row(
		"Ground",
		"Graphite or paper. " + GROUND_HINT,
		func(enabled: bool) -> void: Save.set_ground_light(enabled),
		Save.ground_light
	)
	_add_row(
		"Ghost piece",
		"Show where the piece will land",
		func(enabled: bool) -> void: Save.set_ghost_enabled(enabled),
		Save.ghost_enabled
	)
	_add_row(
		"Left-handed",
		"Mirror the touch controls. " + GROUND_HINT,
		func(enabled: bool) -> void: Save.set_left_handed(enabled),
		Save.left_handed
	)
	_add_row(
		"Large buttons",
		"Bigger touch controls. " + GROUND_HINT,
		func(enabled: bool) -> void: Save.set_large_buttons(enabled),
		Save.large_buttons
	)
	_add_row(
		"Haptics",
		"Vibrate on line clears",
		func(enabled: bool) -> void: Save.set_haptics(enabled),
		Save.haptics
	)


func _add_row(label: String, hint: String, on_changed: Callable, initial: bool) -> void:
	var row := Button.new()
	# A bordered card like the mode picker's. Pressing it flips the switch it contains.
	row.custom_minimum_size = Vector2(0, 132)
	row.theme_type_variation = &"CardButton"
	row.focus_mode = Control.FOCUS_NONE

	var layout := HBoxContainer.new()
	# Inset inside the card border: content margins do not affect child nodes.
	layout.set_anchors_preset(Control.PRESET_FULL_RECT)
	layout.offset_left = 24
	layout.offset_right = -24
	layout.offset_top = 20
	layout.offset_bottom = -20
	layout.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layout.add_theme_constant_override("separation", 20)
	row.add_child(layout)

	var text := VBoxContainer.new()
	text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	text.add_theme_constant_override("separation", 4)
	layout.add_child(text)

	var name_label := Label.new()
	name_label.text = label.to_upper()
	text.add_child(name_label)
	if hint != "":
		var hint_label := Label.new()
		hint_label.text = hint
		hint_label.theme_type_variation = &"Muted"
		# Wrap inside the card instead of running off the screen.
		hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		hint_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		text.add_child(hint_label)

	var switch := ToggleSwitch.new()
	switch.on = initial
	switch.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	layout.add_child(switch)

	row.pressed.connect(
		func() -> void:
			switch.on = not switch.on
			on_changed.call(switch.on)
	)
	_list.add_child(row)
	_switches[label] = switch


func _on_close_pressed() -> void:
	closed.emit()
