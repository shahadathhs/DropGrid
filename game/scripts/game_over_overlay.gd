extends Control

signal play_again_pressed
signal menu_pressed

@onready var _score_label: Label = %ScoreLabel
@onready var _best_label: Label = %BestLabel


func show_results(final_score: int, best_score: int, improved: bool) -> void:
	_score_label.text = "Score: %d" % final_score
	if improved:
		_best_label.text = "New best: %d" % best_score
		_best_label.add_theme_color_override("font_color", Palette.SUCCESS)
	else:
		_best_label.text = "Best: %d" % best_score
		_best_label.remove_theme_color_override("font_color")


func _on_play_again_pressed() -> void:
	play_again_pressed.emit()


func _on_menu_pressed() -> void:
	menu_pressed.emit()
