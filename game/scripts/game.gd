extends Control
## Game screen: owns the GameController, drives its timer, and wires its
## signals to the board view, HUD, touch controls, and overlays.

const MENU_SCENE := "res://scenes/main_menu.tscn"

@onready var _board_view: Control = %BoardView
@onready var _hud: Node = %Hud
@onready var _touch_controls: Node = %TouchControls
@onready var _pause_button: Button = %PauseButton
@onready var _pause_overlay: Control = %PauseOverlay
@onready var _game_over_overlay: Control = %GameOverOverlay

var game: GameController
var _window_had_focus := false


func _ready() -> void:
	_start_new_game()

	_pause_button.pressed.connect(func(): game.set_paused(true))
	_pause_overlay.resume_pressed.connect(func(): game.set_paused(false))
	_pause_overlay.restart_pressed.connect(_restart)
	_pause_overlay.menu_pressed.connect(_go_to_menu)
	_game_over_overlay.play_again_pressed.connect(_restart)
	_game_over_overlay.menu_pressed.connect(_go_to_menu)

	_pause_overlay.hide()
	_game_over_overlay.hide()


func _process(delta: float) -> void:
	game.advance(delta)


func _notification(what: int) -> void:
	# Backgrounding the app (e.g. a phone call, switching apps) should pause
	# the game rather than let it keep falling unseen. On Android the window
	# can briefly start out unfocused during launch, so treat focus loss as
	# backgrounding only after the window has actually held focus once.
	if what == NOTIFICATION_APPLICATION_FOCUS_IN:
		_window_had_focus = true
	elif what == NOTIFICATION_APPLICATION_PAUSED \
			or (what == NOTIFICATION_APPLICATION_FOCUS_OUT and _window_had_focus):
		if is_instance_valid(game) and game.state == GameController.State.PLAYING:
			game.set_paused(true)


func _on_pause_changed(is_paused: bool) -> void:
	_pause_overlay.visible = is_paused
	_pause_button.disabled = is_paused


func _on_game_over(final_score: int) -> void:
	Sfx.play("game_over")
	var improved := Save.offer_score(final_score)
	_game_over_overlay.show_results(final_score, Save.best_score, improved)
	_game_over_overlay.show()
	_pause_button.disabled = true


func _restart() -> void:
	_pause_overlay.hide()
	_game_over_overlay.hide()
	_pause_button.disabled = false
	_start_new_game()


func _start_new_game() -> void:
	game = GameController.new()
	_board_view.setup(game)
	_hud.setup(game)
	_touch_controls.setup(game)
	game.piece_locked.connect(func(_cells): Sfx.play("lock"))
	game.piece_moved.connect(func(): Sfx.play("move"))
	game.piece_rotated.connect(func(): Sfx.play("rotate"))
	game.lines_cleared.connect(func(_rows, _pts): Sfx.play("line_clear"))
	game.game_over.connect(_on_game_over)
	game.pause_changed.connect(_on_pause_changed)


func _go_to_menu() -> void:
	get_tree().change_scene_to_file(MENU_SCENE)
