extends Control
## Game over screen. It shows the results that game.gd passes in and reports the two buttons.

signal play_again_pressed
signal levels_pressed
signal menu_pressed

@onready var _eyebrow: Label = %Eyebrow
@onready var _heading: Label = %Heading
@onready var _heading_accent: Label = %HeadingAccent
@onready var _score_label: Label = %ScoreLabel
@onready var _lines_label: Label = %LinesLabel
@onready var _level_label: Label = %LevelLabel
@onready var _best_label: Label = %BestLabel


## Fills the screen with the finished run. "improved" means this run set a new personal best.
func show_results(final_score: int, best_score: int, improved: bool, lines: int = 0, level: int = 1) -> void:
	_score_label.text = UiFormat.thousands(final_score)
	_lines_label.text = str(lines)
	_level_label.text = str(level)
	_best_label.text = UiFormat.thousands(best_score)
	# Wording follows the prototype: a new best gets a celebratory heading.
	_eyebrow.text = "New personal best" if improved else "Run over"
	_heading.text = "Beautiful." if improved else "Nice run."
	_heading_accent.text = "A new best." if improved else "One more?"
	if improved:
		_best_label.add_theme_color_override("font_color", Palette.SUCCESS)
	else:
		_best_label.remove_theme_color_override("font_color")


func _on_play_again_pressed() -> void:
	play_again_pressed.emit()


func _on_levels_pressed() -> void:
	levels_pressed.emit()


func _on_menu_pressed() -> void:
	menu_pressed.emit()
