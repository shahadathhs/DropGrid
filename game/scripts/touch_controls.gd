extends Node
## Converts button presses into gameplay actions. Never edits board state directly.

var game: GameController
var _repeating_direction := 0

@onready var _left: Button = %LeftButton
@onready var _right: Button = %RightButton
@onready var _rotate: Button = %RotateButton
@onready var _hold: Button = %HoldButton
@onready var _soft_drop: Button = %SoftDropButton
@onready var _hard_drop: Button = %HardDropButton

@onready var _repeat_timer: Timer = %RepeatTimer


func setup(controller: GameController) -> void:
	game = controller
	_left.button_down.connect(_on_direction_down.bind(-1))
	_left.button_up.connect(_on_direction_up)
	_right.button_down.connect(_on_direction_down.bind(1))
	_right.button_up.connect(_on_direction_up)
	_rotate.pressed.connect(func(): game.rotate_piece())
	_hold.pressed.connect(func(): game.hold())
	_soft_drop.button_down.connect(func(): game.set_soft_drop(true))
	_soft_drop.button_up.connect(func(): game.set_soft_drop(false))
	_hard_drop.pressed.connect(func(): game.hard_drop())
	_repeat_timer.timeout.connect(_on_repeat_timeout)
	_apply_layout()


## Left-handed mirrors the button order; large buttons scale the cluster.
func _apply_layout() -> void:
	var root := _left.get_parent_control()
	if root != null:
		root.layout_direction = (
			Control.LAYOUT_DIRECTION_RTL if Save.left_handed else Control.LAYOUT_DIRECTION_LTR
		)
		var factor := 1.2 if Save.large_buttons else 1.0
		root.scale = Vector2(factor, factor)


func _on_direction_down(dx: int) -> void:
	_repeating_direction = dx
	game.move(dx)
	_repeat_timer.wait_time = GameConfig.MOVE_REPEAT_DELAY
	_repeat_timer.start()


func _on_direction_up() -> void:
	_repeating_direction = 0
	_repeat_timer.stop()


func _on_repeat_timeout() -> void:
	if _repeating_direction == 0:
		_repeat_timer.stop()
		return
	game.move(_repeating_direction)
	# After the initial delay, repeat quickly until the button is released.
	_repeat_timer.wait_time = GameConfig.MOVE_REPEAT_INTERVAL
	_repeat_timer.start()
