extends Node
## Autoload singleton ("DevicePreview"): desktop-only mobile screen simulation.
## On PC, shrinks the window to a phone-shaped size so layouts can be checked
## without a device, and lets you switch sizes while the game is running.
## Inert on mobile/web exports (guarded by feature checks below).
##
## Keys while running on desktop:
##   F9  cycle device size
##   F10 rotate portrait/landscape
##
## Screenshots (debug desktop only), for checking layouts without a phone:
##   godot --path game res://scenes/game.tscn -- --shot=/tmp/a.png --size=390x844 --demo
## --demo fills the game board with a fixed mid-game position; --overlay=pause or
## --overlay=gameover opens that overlay. Nothing is written to the save file.

## Real logical point sizes of common devices. Aspect is what matters most;
## the window is scaled down if it would not fit the host screen.
const DEVICES: Array[Vector2i] = [
	Vector2i(375, 667), # iPhone SE
	Vector2i(390, 844), # iPhone 14/15
	Vector2i(430, 932), # iPhone 15 Pro Max
	Vector2i(360, 800), # Galaxy S20
	Vector2i(412, 915), # Pixel 7
	Vector2i(600, 969), # small tablet
	Vector2i(820, 1180), # iPad Air
]
const DEVICE_NAMES: Array[String] = [
	"iPhone SE", "iPhone 14/15", "iPhone 15 Pro Max",
	"Galaxy S20", "Pixel 7", "Tablet 600x969", "iPad Air",
]
const NEXT_KEY := KEY_F9
const ROTATE_KEY := KEY_F10
## Fraction of the host screen height the window may use.
const MAX_SCREEN_FRACTION := 0.85
## Preview windows open at this multiple of the device's logical points, so
## the game renders at phone-like pixel density instead of downscaling the
## 720-wide design canvas (which makes everything blurry on the desktop).
const PREVIEW_DENSITY := 2.0

var _index := 1 # start on iPhone 14/15, closest to a typical target device
var _landscape := false
## Screenshot mode, set from command-line user args (after "--").
var _custom_size := Vector2i.ZERO
var _shot_path := ""
var _demo := false
var _overlay := ""


func _ready() -> void:
	# No-op on phones/tablets/web and in release exports.
	if not OS.has_feature("pc") or not OS.is_debug_build():
		set_process(false)
		set_process_unhandled_key_input(false)
		return
	_read_args()
	_apply()
	if _shot_path != "":
		_take_shot.call_deferred()


func _read_args() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--shot="):
			_shot_path = arg.trim_prefix("--shot=")
		elif arg.begins_with("--size="):
			var parts := arg.trim_prefix("--size=").split("x")
			_custom_size = Vector2i(int(parts[0]), int(parts[1]))
		elif arg == "--demo":
			_demo = true
		elif arg.begins_with("--overlay="):
			_overlay = arg.trim_prefix("--overlay=")


func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.physical_keycode:
			NEXT_KEY:
				_index = (_index + 1) % DEVICES.size()
				_apply()
			ROTATE_KEY:
				_landscape = not _landscape
				_apply()


func _apply() -> void:
	var size := DEVICES[_index] if not _landscape else Vector2i(DEVICES[_index].y, DEVICES[_index].x)
	if _custom_size != Vector2i.ZERO:
		size = _custom_size
	var screen := DisplayServer.screen_get_usable_rect(DisplayServer.window_get_current_screen())
	# Open at phone pixel density, then shrink to fit the host screen.
	var points := Vector2(size) * PREVIEW_DENSITY
	var fit := minf(1.0, float(screen.size.y) * MAX_SCREEN_FRACTION / points.y)
	var window := get_window()
	window.size = Vector2i(points * fit)
	window.move_to_center()
	window.title = "DropGrid - %s%s (%dx%d)" % [
		DEVICE_NAMES[_index], " landscape" if _landscape else "", size.x, size.y,
	]


func _take_shot() -> void:
	for i in 3:
		await get_tree().process_frame
	var scene := get_tree().current_scene
	if _demo and scene != null and "game" in scene:
		_stage_demo(scene)
	for i in 4:
		await get_tree().process_frame
	# Losing window focus (another window opening) pauses the game; undo that here.
	if _overlay != "pause" and scene != null and "game" in scene \
			and scene.game.state == GameController.State.PAUSED:
		scene.game.set_paused(false)
		for i in 3:
			await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(_shot_path)
	get_tree().quit()


## A fixed mid-game position: a stack with holes, an active piece in the air
## (so the ghost shows), and non-zero score, lines, and level.
func _stage_demo(scene: Node) -> void:
	scene.set_process(false) # freeze falling
	var game: GameController = scene.game
	var rows := [
		"..........",
		"......4...",
		"7....444..",
		"77.3.66.1.",
		"7.333.6..1",
		"25522.6611",
		"2554266.11",
		"3333.22551",
	]
	var top := game.board.rows - rows.size()
	for r in rows.size():
		for c in rows[r].length():
			var ch: String = rows[r][c]
			if ch != ".":
				game.board.lock_cells([Vector2i(c, top + r)], Vector2i.ZERO, int(ch))
	game.active_type = PieceData.Type.T
	game.active_rotation = 0
	game.active_position = Vector2i(3, 5)
	game.score = 12480
	game.lines = 37
	game.level = 4
	game.score_changed.emit(game.score)
	game.lines_changed.emit(game.lines)
	game.level_changed.emit(game.level)
	game.board_changed.emit()
	match _overlay:
		"pause":
			game.set_paused(true)
		"gameover":
			var overlay := scene.get_node("%GameOverOverlay")
			overlay.show_results(game.score, 18200, false, game.lines, game.level)
			overlay.show()
