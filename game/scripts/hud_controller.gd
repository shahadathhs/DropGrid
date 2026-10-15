extends Node
## Updates the stats bar (lines, score, next piece, drop speed) and the level
## pill from GameController signals. Reads values from GameController signals;
## never computes scoring itself. The drop readout uses the same rule as the
## controller: GameController.fall_interval(level).

@onready var _score_label: Label = %ScoreLabel
@onready var _lines_label: Label = %LinesLabel
@onready var _level_label: Label = %LevelLabel
@onready var _level_pill: Label = %LevelPillLabel
@onready var _drop_label: Label = %DropLabel
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


func _on_score_changed(score: int) -> void:
	_score_label.text = UiFormat.thousands(score)


func _on_lines_changed(lines: int) -> void:
	_lines_label.text = str(lines)


func _on_level_changed(level: int) -> void:
	_level_label.text = str(level)
	_level_pill.text = "Level %02d" % level
	# Drop readout: seconds between automatic steps at this level.
	_drop_label.text = "%.2fs" % GameController.fall_interval(level)


func _on_piece_spawned() -> void:
	_next_preview.show_type(game.next_type)
