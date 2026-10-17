extends Control
## Top 50 leaderboard. Loading, empty, and unreachable states are shown in the status label.
## The current player's row is a filled ink bar, so it reads without relying on hue.

const MENU_SCENE := "res://scenes/main_menu.tscn"
const SIGN_IN_SCENE := "res://scenes/sign_in.tscn"

@onready var _status_box: Control = %StatusBox
@onready var _status_label: Label = %StatusLabel
@onready var _retry_button: Button = %RetryButton
@onready var _row_list: VBoxContainer = %RowList
@onready var _sign_in_box: Control = %SignInBox


func _ready() -> void:
	Sync.leaderboard_ready.connect(_on_leaderboard_ready)
	Sync.request_failed.connect(_on_request_failed)
	# Guests can read the board but cannot appear on it, so offer the sign-in screen.
	_sign_in_box.visible = not Sync.is_signed_in() and Sync.is_online_enabled()
	_load_entries()


func _load_entries() -> void:
	_clear_rows()
	_retry_button.hide()
	_status_label.text = "Loading"
	_status_box.show()
	Sync.fetch_leaderboard()


func _clear_rows() -> void:
	for row in _row_list.get_children():
		row.queue_free()


func _on_leaderboard_ready(entries: Array) -> void:
	_retry_button.hide()
	if entries.is_empty():
		_status_label.text = "No scores yet"
		return
	_status_box.hide()
	for entry in entries:
		_add_row(entry)


func _on_request_failed(action: String, _message: String) -> void:
	if action != "leaderboard":
		return
	_clear_rows()
	_status_label.text = "Can't reach the server"
	_retry_button.show()
	_status_box.show()


## One flat row: rank | name | best score. The player's own row sits on a filled ink bar.
func _add_row(entry: Dictionary) -> void:
	var username := str(entry.get("username", ""))
	var is_me := (
		Sync.is_signed_in() and username != "" and username.to_lower() == Sync.username().to_lower()
	)
	var ink := Palette.ACCENT_INK if is_me else Palette.TEXT

	var row := VBoxContainer.new()
	row.add_theme_constant_override("separation", 0)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var stack := MarginContainer.new()
	stack.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(stack)
	if is_me:
		var bar := ColorRect.new()
		bar.color = Palette.ACCENT
		bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
		stack.add_child(bar)

	var pad := MarginContainer.new()
	pad.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for side in ["left", "right"]:
		pad.add_theme_constant_override("margin_" + side, 18 if is_me else 0)
	for side in ["top", "bottom"]:
		pad.add_theme_constant_override("margin_" + side, 18)
	stack.add_child(pad)
	var line := HBoxContainer.new()
	line.add_theme_constant_override("separation", 18)
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pad.add_child(line)

	var rank := _make_label("%d" % int(entry.get("rank", 0)), &"StatValue", ink, 66)
	line.add_child(rank)
	var name_label := _make_label(username, &"", ink, 0)
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	line.add_child(name_label)
	line.add_child(
		_make_label(UiFormat.thousands(int(entry.get("best_score", 0))), &"StatValue", ink, 0)
	)

	if not is_me:
		var rule := ColorRect.new()
		rule.color = Palette.LINE
		rule.custom_minimum_size = Vector2(0, 2)
		rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(rule)
	_row_list.add_child(row)


## Builds one label. min_width 0 means "no minimum".
func _make_label(text: String, variation: StringName, color: Color, min_width: int) -> Label:
	var label := Label.new()
	label.text = text
	if variation != &"":
		label.theme_type_variation = variation
	label.add_theme_color_override("font_color", color)
	label.custom_minimum_size = Vector2(min_width, 0)
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label


func _on_retry_pressed() -> void:
	_load_entries()


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file(MENU_SCENE)


func _on_sign_in_pressed() -> void:
	get_tree().change_scene_to_file(SIGN_IN_SCENE)
