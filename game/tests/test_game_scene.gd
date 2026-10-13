extends GutTest
## Scene-level checks: the game screen must actually play when it runs.

var _scene: Control


func before_each() -> void:
	_scene = load("res://scenes/game.tscn").instantiate()
	add_child_autofree(_scene)


func test_piece_falls_when_the_scene_processes_frames() -> void:
	var start_y: int = _scene.game.active_position.y
	simulate(_scene, 120, 1.0 / 60.0) # ~2 seconds of frames
	assert_gt(_scene.game.active_position.y, start_y, "the active piece should have fallen")


func test_board_view_gets_a_real_size_from_the_layout() -> void:
	# Regression: wrapping the view in a CenterContainer collapsed it to 0x0,
	# which drew the whole board as an invisible dot.
	await get_tree().process_frame
	var board: Control = _scene.get_node("%BoardView")
	assert_gt(board.size.x, 0.0, "board width must not be zero")
	assert_gt(board.size.y, 0.0, "board height must not be zero")


func test_focus_out_during_launch_does_not_pause_the_game() -> void:
	# Android can deliver a focus-out during launch, before the window was
	# ever focused; the game must keep playing through it.
	_scene.notification(Control.NOTIFICATION_APPLICATION_FOCUS_OUT)
	assert_eq(_scene.game.state, GameController.State.PLAYING)
	var start_y: int = _scene.game.active_position.y
	simulate(_scene, 60, 1.0 / 60.0)
	assert_gt(_scene.game.active_position.y, start_y, "the piece should still fall")


func test_backgrounding_after_focus_pauses_visibly() -> void:
	_scene.notification(Control.NOTIFICATION_APPLICATION_FOCUS_IN)
	_scene.notification(Control.NOTIFICATION_APPLICATION_FOCUS_OUT)
	assert_eq(_scene.game.state, GameController.State.PAUSED)
	var overlay: Control = _scene.get_node("%PauseOverlay")
	assert_true(overlay.visible, "a paused game must show the pause overlay")
