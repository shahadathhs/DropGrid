extends Control

signal resume_pressed
signal restart_pressed
signal menu_pressed


func _on_resume_pressed() -> void:
	resume_pressed.emit()


func _on_restart_pressed() -> void:
	restart_pressed.emit()


func _on_menu_pressed() -> void:
	menu_pressed.emit()
