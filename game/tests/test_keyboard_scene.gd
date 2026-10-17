extends GutTest
## Scene-level: synthetic key events drive the controller through the touch controls.

var _scene: Control


func before_each() -> void:
	_scene = load("res://scenes/game.tscn").instantiate()
	add_child_autofree(_scene)


func _key(keycode: int, pressed: bool = true, echo: bool = false) -> void:
	var event := InputEventKey.new()
	event.keycode = keycode
	event.physical_keycode = keycode
	event.pressed = pressed
	event.echo = echo
	_scene._input(event)


func test_left_key_moves_the_piece_and_release_stops_repeat() -> void:
	var start_x: int = _scene.game.active_position.x
	_key(KEY_LEFT)
	assert_eq(_scene.game.active_position.x, start_x - 1)
	_key(KEY_LEFT, false)
	assert_eq(_scene.get_node("%TouchControls")._repeating_direction, 0)


func test_right_key_moves_the_piece() -> void:
	var start_x: int = _scene.game.active_position.x
	_key(KEY_D)
	assert_eq(_scene.game.active_position.x, start_x + 1)


func test_echo_is_ignored() -> void:
	var start_x: int = _scene.game.active_position.x
	_key(KEY_LEFT, true, true)
	assert_eq(_scene.game.active_position.x, start_x)


func test_up_key_rotates() -> void:
	var start_rotation: int = _scene.game.active_rotation
	_key(KEY_UP)
	assert_ne(_scene.game.active_rotation, start_rotation)


func test_space_hard_drops() -> void:
	var locked := [0]
	_scene.game.piece_locked.connect(func(_cells): locked[0] += 1)
	_key(KEY_SPACE)
	assert_eq(locked[0], 1, "space should lock the piece at once")


func test_down_key_soft_drops_while_held() -> void:
	_key(KEY_DOWN)
	assert_true(_scene.game.soft_dropping)
	_key(KEY_DOWN, false)
	assert_false(_scene.game.soft_dropping)


func test_pause_key_toggles_and_blocks_other_keys() -> void:
	_key(KEY_P)
	assert_eq(_scene.game.state, GameController.State.PAUSED)
	assert_true(_scene.get_node("%PauseOverlay").visible)
	var start_x: int = _scene.game.active_position.x
	_key(KEY_LEFT)
	assert_eq(_scene.game.active_position.x, start_x, "keys do nothing while paused")
	_key(KEY_ESCAPE)
	assert_eq(_scene.game.state, GameController.State.PLAYING)


func test_pause_key_does_nothing_on_the_game_over_screen() -> void:
	_scene.game.set_paused(true)
	_scene._end_run()
	assert_true(_scene.get_node("%GameOverOverlay").visible)
	_key(KEY_P)
	assert_true(_scene.get_node("%GameOverOverlay").visible)
	assert_eq(_scene.game.state, GameController.State.PAUSED)
