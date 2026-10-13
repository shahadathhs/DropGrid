extends Control

const MENU_SCENE := "res://scenes/main_menu.tscn"


func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file(MENU_SCENE)
