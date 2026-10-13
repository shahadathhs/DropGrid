extends Control
## Pause panel shown over the dimmed board. It only reports button presses;
## game.gd decides what resume, end run, and quit do.

signal resume_pressed
signal end_run_pressed
signal menu_pressed


func _on_resume_pressed() -> void:
	resume_pressed.emit()


## Ends the run now: the game shows its game over results, as if the board filled up.
func _on_end_run_pressed() -> void:
	end_run_pressed.emit()


func _on_menu_pressed() -> void:
	menu_pressed.emit()
