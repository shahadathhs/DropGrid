extends Control
## Mode picker: one card per mode. Marathon hands over to the start-level
## picker; the other modes start their run directly.

const GAME_SCENE := "res://scenes/game.tscn"
const LEVELS_SCENE := "res://scenes/levels.tscn"

@onready var _cards: VBoxContainer = %Cards


func _ready() -> void:
	for mode_value in [
		GameMode.Mode.MARATHON,
		GameMode.Mode.SPRINT,
		GameMode.Mode.ULTRA,
		GameMode.Mode.DAILY,
		GameMode.Mode.ZEN,
	]:
		_cards.add_child(_make_card(GameMode.new(mode_value)))


func _make_card(mode: GameMode) -> Button:
	var card := Button.new()
	card.custom_minimum_size = Vector2(0, 132)
	card.focus_mode = Control.FOCUS_NONE
	_add_card_styles(card)

	var layout := HBoxContainer.new()
	# Inset inside the stylebox border: content margins do not affect child nodes.
	layout.set_anchors_preset(Control.PRESET_FULL_RECT)
	layout.offset_left = 24
	layout.offset_right = -24
	layout.offset_top = 20
	layout.offset_bottom = -20
	layout.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layout.add_theme_constant_override("separation", 20)
	card.add_child(layout)

	var text := VBoxContainer.new()
	text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	text.add_theme_constant_override("separation", 4)
	layout.add_child(text)

	var name_label := Label.new()
	name_label.text = mode.display_name().to_upper()
	text.add_child(name_label)
	var tagline := Label.new()
	tagline.text = mode.tagline()
	tagline.theme_type_variation = &"Muted"
	tagline.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tagline.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text.add_child(tagline)

	card.pressed.connect(func(): _start(mode))
	return card


## One bordered surface per card: palette surface fill, line border, the
## single 4px cell radius. Hover raises the surface, press goes deeper.
func _add_card_styles(card: Button) -> void:
	var states := {
		"normal": [Palette.SURFACE, Palette.LINE],
		"hover": [Palette.SURFACE_2, Palette.LINE_STRONG],
		"pressed": [Palette.SURFACE_3, Palette.LINE_STRONG],
		"focus": [Palette.SURFACE, Palette.LINE],
	}
	for state in states:
		var style := StyleBoxFlat.new()
		style.bg_color = states[state][0]
		style.border_color = states[state][1]
		style.set_border_width_all(2)
		style.set_corner_radius_all(4)
		card.add_theme_stylebox_override(state, style)


func _on_close_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _start(mode: GameMode) -> void:
	PendingMode.pending = mode
	StartLevel.pending = 1 if mode.mode != GameMode.Mode.MARATHON else StartLevel.pending
	var target := LEVELS_SCENE if mode.mode == GameMode.Mode.MARATHON else GAME_SCENE
	get_tree().change_scene_to_file(target)
