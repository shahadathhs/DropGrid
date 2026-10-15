extends Control
## Start level picker: one card per level from 1 to GameConfig.MAX_START_LEVEL. A level is
## unlocked once lifetime Save.total_lines reaches 10 * (level - 1). Locked cards are
## disabled; an unlocked card starts a game at that level.

const MENU_SCENE := "res://scenes/main_menu.tscn"
const GAME_SCENE := "res://scenes/game.tscn"
const NODE_MIN_HEIGHT := 96.0

enum NodeState { UNLOCKED, LOCKED }

@onready var _summary_label: Label = %SummaryLabel
@onready var _level_tree: VBoxContainer = %LevelTree


func _ready() -> void:
	var total := Save.total_lines
	_summary_label.text = "%s lines cleared" % UiFormat.thousands(total)
	var newest := highest_unlocked(total)
	for level in range(1, GameConfig.MAX_START_LEVEL + 1):
		_level_tree.add_child(_make_node(level, node_state(level, total), level == newest))


## Pure rule for one card, so tests can check it without a scene.
static func node_state(level: int, total_lines: int) -> NodeState:
	if level >= 1 and level <= GameConfig.MAX_START_LEVEL and total_lines >= lines_to_reach(level):
		return NodeState.UNLOCKED
	return NodeState.LOCKED


## Lifetime lines needed to unlock a level: level 1 is free, level n needs 10 * (n - 1).
static func lines_to_reach(level: int) -> int:
	return GameConfig.LINES_PER_LEVEL * (level - 1)


## The highest level the player may start at, capped at MAX_START_LEVEL.
static func highest_unlocked(total_lines: int) -> int:
	return mini(GameController.level_for_lines(total_lines), GameConfig.MAX_START_LEVEL)


func _make_node(level: int, state: NodeState, newest: bool) -> Button:
	var button := Button.new()
	button.theme_type_variation = &"CardButtonCurrent" if newest else &"CardButton"
	button.custom_minimum_size = Vector2(0, NODE_MIN_HEIGHT)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.disabled = state == NodeState.LOCKED
	if state == NodeState.UNLOCKED:
		button.pressed.connect(_on_node_pressed.bind(level))
	else:
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
	if state == NodeState.UNLOCKED:
		return "Drop %.2fs" % GameController.fall_interval(level)
	return "Unlocks at %d lines" % lines_to_reach(level)


func _on_node_pressed(level: int) -> void:
	if node_state(level, Save.total_lines) != NodeState.UNLOCKED:
		return
	StartLevel.pending = level
	get_tree().change_scene_to_file(GAME_SCENE)


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file(MENU_SCENE)
