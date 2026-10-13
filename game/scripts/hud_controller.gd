extends Node
## Updates the score, best, level, progress line, and next piece from GameController signals.
## Reads values from GameController signals; never computes scoring itself.
## The progress line only does display math (lines into the current level) with the
## same rule the controller uses: a new level every GameConfig.LINES_PER_LEVEL lines.

@onready var _score_label: Label = %ScoreLabel
@onready var _best_label: Label = %BestLabel
@onready var _lines_label: Label = %LinesLabel
@onready var _level_label: Label = %LevelLabel
@onready var _level_pill: Label = %LevelPillLabel
@onready var _drop_label: Label = %DropLabel
@onready var _progress_bar: ProgressBar = %ProgressBar
@onready var _progress_label: Label = %ProgressLabel
@onready var _next_preview: Control = %NextPreview

var game: GameController


func setup(controller: GameController) -> void:
	game = controller
	game.score_changed.connect(_on_score_changed)
	game.lines_changed.connect(_on_lines_changed)
	game.level_changed.connect(_on_level_changed)
	game.piece_spawned.connect(_on_piece_spawned)
	_on_score_changed(game.score)
	_on_lines_changed(game.lines)
	_on_level_changed(game.level)
	_on_piece_spawned()
	_update_best()


func _update_best() -> void:
	_best_label.text = UiFormat.thousands(Save.best_score)


func _on_score_changed(score: int) -> void:
	_score_label.text = UiFormat.thousands(score)


func _on_lines_changed(lines: int) -> void:
	_lines_label.text = str(lines)
	_update_progress(lines)


func _on_level_changed(level: int) -> void:
	_level_label.text = str(level)
	_level_pill.text = "Level %02d" % level
	# Drop card: seconds between automatic steps at this level, from the controller's rule.
	_drop_label.text = "%.2fs" % GameController.fall_interval(level)
	_update_progress(game.lines)


func _on_piece_spawned() -> void:
	_next_preview.show_type(game.next_type)


## Progress bar and text: how far into the current level the player is.
func _update_progress(lines: int) -> void:
	var into_level := lines % GameConfig.LINES_PER_LEVEL
	_progress_bar.value = into_level
	var to_next := GameConfig.LINES_PER_LEVEL - into_level
	_progress_label.text = "%d lines to level %02d" % [to_next, game.level + 1]
