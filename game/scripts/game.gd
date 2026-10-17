extends Control
## Game screen: owns the GameController, drives its timer, and wires its
## signals to the board view, HUD, touch controls, and overlays.

const MENU_SCENE := "res://scenes/main_menu.tscn"
const LEVELS_SCENE := "res://scenes/levels.tscn"
## Haptics only run on phones; desktop and web builds never vibrate.
const HAPTIC_OS_NAMES: Array[String] = ["Android", "iOS"]
const HAPTIC_DURATION_MS := 20
## Design margin at the top and bottom of the screen, in design units.
const EDGE_MARGIN := 24
## Extra room kept between the controls and a system bar.
const SAFE_AREA_PADDING := 12

var game: GameController
## Start level of this run; Play again repeats it.
var _start_level := 1
var _window_had_focus := false

@onready var _margin: MarginContainer = %Margin
@onready var _board_view: Control = %BoardView
@onready var _hud: Node = %Hud
@onready var _touch_controls: Node = %TouchControls
@onready var _pause_button: Button = %PauseButton
@onready var _pause_overlay: Control = %PauseOverlay
@onready var _game_over_overlay: Control = %GameOverOverlay


func _ready() -> void:
	_apply_safe_area()
	_start_level = StartLevel.take()
	_start_new_game()

	_pause_button.pressed.connect(func(): game.set_paused(true))
	_pause_overlay.resume_pressed.connect(func(): game.set_paused(false))
	_pause_overlay.end_run_pressed.connect(_end_run)
	_pause_overlay.menu_pressed.connect(_go_to_menu)
	_game_over_overlay.play_again_pressed.connect(_restart)
	_game_over_overlay.levels_pressed.connect(_go_to_levels)
	_game_over_overlay.menu_pressed.connect(_go_to_menu)

	_pause_overlay.hide()
	_game_over_overlay.hide()


## Keeps the HUD and controls out of camera cutouts and gesture bars on phones.
func _apply_safe_area() -> void:
	if not OS.has_feature("mobile"):
		return
	var window_size := DisplayServer.window_get_size()
	if window_size.x <= 0:
		return
	var safe := DisplayServer.get_display_safe_area()
	var to_design := size.x / float(window_size.x)
	var top := maxf(0.0, safe.position.y) * to_design
	var bottom := maxf(0.0, window_size.y - safe.end.y) * to_design
	_margin.add_theme_constant_override(
		"margin_top", maxi(EDGE_MARGIN, int(top) + SAFE_AREA_PADDING)
	)
	_margin.add_theme_constant_override(
		"margin_bottom", maxi(EDGE_MARGIN, int(bottom) + SAFE_AREA_PADDING)
	)


func _process(delta: float) -> void:
	game.advance(delta)


func _notification(what: int) -> void:
	# Backgrounding the app (e.g. a phone call, switching apps) should pause
	# the game rather than let it keep falling unseen. On Android the window
	# can briefly start out unfocused during launch, so treat focus loss as
	# backgrounding only after the window has actually held focus once.
	if what == NOTIFICATION_APPLICATION_FOCUS_IN:
		_window_had_focus = true
	elif (
		what == NOTIFICATION_APPLICATION_PAUSED
		or (what == NOTIFICATION_APPLICATION_FOCUS_OUT and _window_had_focus)
	):
		if is_instance_valid(game) and game.state == GameController.State.PLAYING:
			game.set_paused(true)


func _on_pause_changed(is_paused: bool) -> void:
	_pause_overlay.visible = is_paused
	_pause_button.disabled = is_paused


func _on_lines_cleared(_rows: Array[int], _points: int) -> void:
	Sfx.play("line_clear")
	_buzz()


func _on_game_over(final_score: int) -> void:
	Sfx.play("game_over")
	_buzz()
	var improved := Save.record_run(final_score, game.lines)
	Sync.push_stats()  # no-op for guests; never blocks the game over screen
	_game_over_overlay.show_results(final_score, Save.best_score, improved, game.lines, game.level)
	_game_over_overlay.show()
	_pause_button.disabled = true


## "End run" in the pause panel: record the run and show the game over screen.
## The controller stays paused, so the board stops moving while the results show.
func _end_run() -> void:
	_pause_overlay.hide()
	_on_game_over(game.score)


func _restart() -> void:
	_pause_overlay.hide()
	_game_over_overlay.hide()
	_pause_button.disabled = false
	_start_new_game()


func _start_new_game() -> void:
	game = GameController.new(-1, _start_level)
	_board_view.setup(game)
	_hud.setup(game)
	_touch_controls.setup(game)
	game.piece_locked.connect(func(_cells): Sfx.play("lock"))
	game.piece_moved.connect(func(): Sfx.play("move"))
	game.piece_rotated.connect(func(): Sfx.play("rotate"))
	game.lines_cleared.connect(_on_lines_cleared)
	game.game_over.connect(_on_game_over)
	game.pause_changed.connect(_on_pause_changed)


func _go_to_menu() -> void:
	get_tree().change_scene_to_file(MENU_SCENE)


func _go_to_levels() -> void:
	get_tree().change_scene_to_file(LEVELS_SCENE)


## Short vibration on line clears and game over, when the Haptics setting is on.
func _buzz() -> void:
	if should_vibrate(Save.haptics, OS.get_name()):
		Input.vibrate_handheld(HAPTIC_DURATION_MS)


## Pure check so tests can cover the platform rule without a device.
static func should_vibrate(haptics_on: bool, os_name: String) -> bool:
	return haptics_on and HAPTIC_OS_NAMES.has(os_name)
