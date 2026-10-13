extends Control
## Top 50 leaderboard. Loading, empty, and unreachable states are shown in the status label.
## The current player's row is highlighted and marked "(you)", so the highlight is not color alone.

const MENU_SCENE := "res://scenes/main_menu.tscn"

@onready var _status_box: Control = %StatusBox
@onready var _status_label: Label = %StatusLabel
@onready var _retry_button: Button = %RetryButton
@onready var _row_list: VBoxContainer = %RowList
@onready var _note_label: Label = %NoteLabel


func _ready() -> void:
	Sync.leaderboard_ready.connect(_on_leaderboard_ready)
	Sync.request_failed.connect(_on_request_failed)
	# Guests can read the board but cannot appear on it, so explain how to join.
	_note_label.visible = not Sync.is_signed_in()
	_load_entries()


func _load_entries() -> void:
	_clear_rows()
	_retry_button.hide()
	_status_label.text = "Loading..."
	_status_label.add_theme_color_override("font_color", Palette.TEXT_MUTED)
	_status_box.show()
	Sync.fetch_leaderboard()


func _clear_rows() -> void:
	for row in _row_list.get_children():
		row.queue_free()


func _on_leaderboard_ready(entries: Array) -> void:
	if entries.is_empty():
		_status_label.text = "No scores yet. Be the first on the board."
		return
	_status_box.hide()
	for entry in entries:
		_add_row(entry)


func _on_request_failed(action: String, _message: String) -> void:
	if action != "leaderboard":
		return
	_status_label.text = "Couldn’t reach the leaderboard\nCheck your connection. Your scores still save on this device."
	_status_label.add_theme_color_override("font_color", Palette.WARNING)
	_retry_button.show()
	_status_box.show()


## One leaderboard row: rank, name, best score. The row style comes from the theme (LeaderRow or LeaderRowMe).
func _add_row(entry: Dictionary) -> void:
	var username := str(entry.get("username", ""))
	var is_me := Sync.is_signed_in() and username != "" and username.to_lower() == Sync.username().to_lower()

	var panel := PanelContainer.new()
	panel.theme_type_variation = &"LeaderRowMe" if is_me else &"LeaderRow"

	var line := HBoxContainer.new()
	line.add_theme_constant_override("separation", 18)
	panel.add_child(line)
	line.add_child(_make_label("%d" % int(entry.get("rank", 0)), Palette.ACCENT if is_me else Palette.TEXT_MUTED, 48, 0))

	var name_text := username + (" (you)" if is_me else "")
	var name_color := Palette.ACCENT if is_me else Palette.TEXT
	var name_label := _make_label(name_text, name_color, 0, 1)
	name_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	line.add_child(name_label)

	line.add_child(_make_label(UiFormat.thousands(int(entry.get("best_score", 0))), Palette.TEXT, 0, 0))
	_row_list.add_child(panel)


## Builds one label. min_width 0 means "no minimum"; expand 1 lets it fill spare space.
func _make_label(text: String, color: Color, min_width: int, expand: int) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_color_override("font_color", color)
	label.custom_minimum_size = Vector2(min_width, 0)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL if expand == 1 else Control.SIZE_SHRINK_BEGIN
	return label


func _on_retry_pressed() -> void:
	_load_entries()


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file(MENU_SCENE)
