extends Control
## Start level picker: one tile per level from 1 to GameConfig.MAX_START_LEVEL. A level is
## unlocked once lifetime Save.total_lines reaches 10 * (level - 1). Locked tiles are
## disabled; an unlocked tile starts a game at that level.

enum NodeState { UNLOCKED, LOCKED }

const MENU_SCENE := "res://scenes/main_menu.tscn"
const GAME_SCENE := "res://scenes/game.tscn"
const TILE_HEIGHT := 132.0

@onready var _summary_label: Label = %SummaryLabel
@onready var _level_tree: GridContainer = %LevelTree
@onready var _needs_label: Label = %NeedsLabel


func _ready() -> void:
	var total := Save.total_lines
	_summary_label.text = (
		"%s %s CLEARED" % [UiFormat.thousands(total), "LINE" if total == 1 else "LINES"]
	)
	for level in range(1, GameConfig.MAX_START_LEVEL + 1):
		_level_tree.add_child(_make_node(level, node_state(level, total)))


## Pure rule for one tile, so tests can check it without a scene.
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


func _make_node(level: int, state: NodeState) -> Button:
	var unlocked := state == NodeState.UNLOCKED
	var button := Button.new()
	button.theme_type_variation = &"PrimaryButton" if unlocked else &"SecondaryButton"
	button.custom_minimum_size = Vector2(0, TILE_HEIGHT)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.disabled = not unlocked
	if unlocked:
		button.pressed.connect(_on_node_pressed.bind(level))
	else:
		button.focus_mode = Control.FOCUS_NONE
		# A disabled button emits no "pressed", but still sees the tap.
		button.gui_input.connect(_on_locked_input.bind(level))

	var number := Label.new()
	number.text = str(level)
	number.theme_type_variation = &"Score"
	number.add_theme_color_override(
		"font_color", Palette.ACCENT_INK if unlocked else Palette.TEXT_MUTED
	)
	number.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	number.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	number.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	number.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(number)
	return button


func _on_locked_input(event: InputEvent, level: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		_needs_label.text = (
			"Level %d needs %s lines" % [level, UiFormat.thousands(lines_to_reach(level))]
		)


func _on_node_pressed(level: int) -> void:
	if node_state(level, Save.total_lines) != NodeState.UNLOCKED:
		return
	StartLevel.pending = level
	PendingMode.pending = GameMode.new(GameMode.Mode.MARATHON)
	get_tree().change_scene_to_file(GAME_SCENE)


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file(MENU_SCENE)
