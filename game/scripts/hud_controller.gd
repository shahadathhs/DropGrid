extends Node
## Updates score/level/lines labels and shows the pause/game-over overlays.
## Reads values from GameController signals; never computes scoring itself.

@onready var _score_label: Label = %ScoreLabel
@onready var _best_label: Label = %BestLabel
@onready var _lines_label: Label = %LinesLabel
@onready var _level_label: Label = %LevelLabel

var game: GameController


func setup(controller: GameController) -> void:
	game = controller
	game.score_changed.connect(_on_score_changed)
	game.lines_changed.connect(_on_lines_changed)
	game.level_changed.connect(_on_level_changed)
	_on_score_changed(game.score)
	_on_lines_changed(game.lines)
	_on_level_changed(game.level)
	_update_best()


func _update_best() -> void:
	_best_label.text = "Best %d" % Save.best_score


func _on_score_changed(score: int) -> void:
	_score_label.text = "%d" % score


func _on_lines_changed(lines: int) -> void:
	_lines_label.text = "Lines %d" % lines


func _on_level_changed(level: int) -> void:
	_level_label.text = "Level %d" % level
