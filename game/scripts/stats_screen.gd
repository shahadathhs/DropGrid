extends Control
## Stats screen: lifetime totals and the per-category bests, all from the
## local save (which is what sync carries to the server).

@onready var _rows: VBoxContainer = %Rows


func _ready() -> void:
	_add_stat("BEST SCORE", UiFormat.thousands(Save.best_score))
	_add_stat("TOTAL LINES", UiFormat.thousands(Save.total_lines))
	_add_stat("GAMES PLAYED", str(Save.games_played))
	for category in GameMode.CATEGORIES:
		var best := Save.counting_best(category)
		if best.is_empty():
			continue
		var label: String
		if category == "sprint":
			label = UiFormat.clock(int(best.get("duration_ms", 0))) + " FOR 40"
		else:
			label = UiFormat.thousands(int(best.get("score", 0)))
		_add_stat(GameMode.from_id(category).display_name().to_upper() + " BEST", label)
	if Save.category_bests.has("daily"):
		var daily: Dictionary = Save.category_bests["daily"]
		_add_stat("DAILY DATE", str(daily.get("date", "")))


func _add_stat(label: String, value: String) -> void:
	var row := HBoxContainer.new()
	var name_label := Label.new()
	name_label.text = label
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_label.theme_type_variation = &"Muted"
	var value_label := Label.new()
	value_label.text = value
	row.add_child(name_label)
	row.add_child(value_label)
	_rows.add_child(row)


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
