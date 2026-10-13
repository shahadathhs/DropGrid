extends Control
## Level path: one node per speed level. Node n is completed once the player has reached
## level n + 1, current when it is the level they are on, and locked before that. Progress
## comes from Save.total_lines, the same rule the profile uses (see GameController.level_for_lines).

const MENU_SCENE := "res://scenes/main_menu.tscn"
const GAME_SCENE := "res://scenes/game.tscn"
const NODE_COUNT := 12
const NODE_MIN_HEIGHT := 96.0

enum NodeState { COMPLETED, CURRENT, LOCKED }

@onready var _summary_label: Label = %SummaryLabel
@onready var _level_tree: VBoxContainer = %LevelTree


func _ready() -> void:
	var total := Save.total_lines
	var current := GameController.level_for_lines(total)
	_summary_label.text = "Total lines: %s · level %02d" % [UiFormat.thousands(total), current]
	for level in range(1, NODE_COUNT + 1):
		_level_tree.add_child(_make_node(level, node_state(level, total)))


## Pure rule for one node, so tests can check it without a scene.
static func node_state(level: int, total_lines: int) -> NodeState:
	if total_lines >= GameConfig.LINES_PER_LEVEL * level:
		return NodeState.COMPLETED
	if level == GameController.level_for_lines(total_lines):
		return NodeState.CURRENT
	return NodeState.LOCKED


## Total lines needed before a level can be reached: level 1 is free, level n needs 10 * (n - 1).
static func lines_to_reach(level: int) -> int:
	return GameConfig.LINES_PER_LEVEL * (level - 1)


func _make_node(level: int, state: NodeState) -> Button:
	var button := Button.new()
	button.theme_type_variation = &"CardButton"
	button.custom_minimum_size = Vector2(0, NODE_MIN_HEIGHT)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.disabled = state == NodeState.LOCKED
	if state == NodeState.CURRENT:
		_style_current(button)
		button.pressed.connect(_on_node_pressed)
	else:
		# Completed nodes show their state but do nothing when tapped.
		button.focus_mode = Control.FOCUS_NONE

	var row := HBoxContainer.new()
	row.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", 15)
	button.add_child(row)

	var tile := PanelContainer.new()
	tile.theme_type_variation = &"SettingIcon"
	tile.custom_minimum_size = Vector2(57, 57)
	tile.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	tile.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(tile)
	var number := Label.new()
	number.text = "%02d" % level
	number.theme_type_variation = &"Value"
	number.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	number.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	number.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tile.add_child(number)

	var copy := VBoxContainer.new()
	copy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	copy.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	copy.add_theme_constant_override("separation", 2)
	copy.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(copy)
	var title := Label.new()
	title.text = "Level %02d" % level
	title.theme_type_variation = &"Title"
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	copy.add_child(title)
	var detail := Label.new()
	detail.text = _detail_text(level, state)
	detail.theme_type_variation = &"Muted"
	detail.mouse_filter = Control.MOUSE_FILTER_IGNORE
	copy.add_child(detail)
	return button


func _detail_text(level: int, state: NodeState) -> String:
	match state:
		NodeState.COMPLETED:
			return "Completed · Drop %.2fs" % GameController.fall_interval(level)
		NodeState.CURRENT:
			return "Current level · Drop %.2fs" % GameController.fall_interval(level)
		_:
			return "Reach level %d at %d lines" % [level, lines_to_reach(level)]


## The current node gets an accent border so it stands out from the other cards.
func _style_current(button: Button) -> void:
	for style_name in ["normal", "hover", "pressed", "hover_pressed"]:
		var box := StyleBoxFlat.new()
		box.bg_color = Palette.ACCENT_SOFT
		box.set_corner_radius_all(18)
		box.set_border_width_all(2)
		box.border_color = Palette.ACCENT
		box.content_margin_left = 27
		box.content_margin_right = 27
		button.add_theme_stylebox_override(style_name, box)


func _on_node_pressed() -> void:
	get_tree().change_scene_to_file(GAME_SCENE)


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file(MENU_SCENE)
