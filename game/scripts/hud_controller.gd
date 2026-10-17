extends Node
## Updates the HUD row (score, level, lines, next piece) from GameController signals.
## Never computes scoring itself.

var game: GameController

@onready var _score_label: Label = %ScoreLabel
@onready var _lines_label: Label = %LinesLabel
@onready var _level_label: Label = %LevelLabel
@onready var _next_preview: Control = %NextPreview


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


func _on_piece_spawned() -> void:
	_next_preview.show_type(game.next_type)
