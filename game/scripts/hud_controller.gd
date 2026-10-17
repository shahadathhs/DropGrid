extends Node
## Updates the HUD row (score, level, lines, time, hold, next queue) from
## GameController signals and state. Never computes scoring itself.

var game: GameController

@onready var _score_label: Label = %ScoreLabel
@onready var _lines_label: Label = %LinesLabel
@onready var _level_label: Label = %LevelLabel
@onready var _time_label: Label = %TimeLabel
@onready var _hold_preview: Control = %HoldPreview
@onready var _queue: Array[Control] = [%NextPreview, %NextPreview2, %NextPreview3]


func _process(_delta: float) -> void:
	if game == null or game.state == GameController.State.GAME_OVER:
		return
	if game.mode.time_limit() >= 0.0:
		_time_label.text = _clock(maxi(0, game.time_left_ms))
	else:
		_time_label.text = _clock(game.elapsed_ms)


func setup(controller: GameController) -> void:
	game = controller
	game.score_changed.connect(_on_score_changed)
	game.lines_changed.connect(_on_lines_changed)
	game.level_changed.connect(_on_level_changed)
	game.piece_spawned.connect(_on_piece_spawned)
	game.hold_changed.connect(_on_hold_changed)
	_on_score_changed(game.score)
	_on_lines_changed(game.lines)
	_on_level_changed(game.level)
	_on_piece_spawned()
	_on_hold_changed()


func _on_score_changed(score: int) -> void:
	_score_label.text = UiFormat.thousands(score)


func _on_lines_changed(lines: int) -> void:
	_lines_label.text = str(lines)


func _on_level_changed(level: int) -> void:
	_level_label.text = str(level)


func _on_piece_spawned() -> void:
	var queue := game.next_queue()
	for i in _queue.size():
		var preview := _queue[i] as Control
		if preview.has_method("show_type"):
			preview.call("show_type", queue[i] if i < queue.size() else -1)


func _on_hold_changed() -> void:
	_hold_preview.call("show_type", game.hold_type)


## mm:ss for a millisecond value.
func _clock(ms: int) -> String:
	@warning_ignore("integer_division")
	var total_seconds := ms / 1000
	@warning_ignore("integer_division")
	return "%d:%02d" % [total_seconds / 60, total_seconds % 60]
