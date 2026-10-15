extends Control
## Profile screen: account name, synced stats, username change, sign out, and account deletion.
## Guests see the same screen with a "Create a profile" button instead of the account actions.
## Stats come from the local save, which the Sync autoload keeps merged with the server.

const MENU_SCENE := "res://scenes/main_menu.tscn"
const SIGN_IN_SCENE := "res://scenes/sign_in.tscn"

@onready var _username_label: Label = %UsernameLabel
@onready var _subtitle_label: Label = %SubtitleLabel
@onready var _settings_overlay: Control = %SettingsOverlay
@onready var _create_button: Button = %CreateProfileButton
@onready var _rename_caption: Label = %RenameCaption
@onready var _name_field: LineEdit = %NameField
@onready var _best_value: Label = %BestValue
@onready var _lines_value: Label = %LinesValue
@onready var _games_value: Label = %GamesValue
@onready var _rename_button: Button = %RenameButton
@onready var _status_label: Label = %StatusLabel
@onready var _sign_out_button: Button = %SignOutButton
@onready var _delete_button: Button = %DeleteButton
@onready var _confirm_box: Control = %ConfirmBox
@onready var _confirm_delete_button: Button = %ConfirmDeleteButton
@onready var _cancel_delete_button: Button = %CancelDeleteButton

## True while a rename request is in flight, so a profile refresh is not reported as "saved".
var _renaming := false


func _ready() -> void:
	Sync.profile_updated.connect(_on_profile_updated)
	Sync.signed_out.connect(_on_signed_out)
	Sync.request_failed.connect(_on_request_failed)
	_confirm_box.hide()
	_set_status("")
	_settings_overlay.hide()
	_settings_overlay.closed.connect(func(): _settings_overlay.hide())
	_refresh_labels()
	_apply_account_state()
	if Sync.is_signed_in():
		Sync.fetch_profile()


## Fills the identity block and stats. Signed-in players show their name; guests see the guest copy.
func _refresh_labels() -> void:
	if Sync.is_signed_in():
		var name_text := Sync.username() if Sync.username() != "" else "Player"
		_username_label.text = name_text
		_subtitle_label.text = "Synced account"
	else:
		_username_label.text = "Guest"
		_subtitle_label.text = "Saved on this device"
	_best_value.text = UiFormat.thousands(Save.best_score)
	_lines_value.text = UiFormat.thousands(Save.total_lines)
	_games_value.text = UiFormat.thousands(Save.games_played)


## Guests get "Create a profile". Signed-in players get rename, sign out, and delete.
func _apply_account_state() -> void:
	var signed_in := Sync.is_signed_in()
	_create_button.visible = not signed_in
	_rename_caption.visible = signed_in
	_name_field.visible = signed_in
	_rename_button.visible = signed_in
	_sign_out_button.visible = signed_in
	_delete_button.visible = signed_in


## Swaps the account actions for the inline delete confirmation.
func _set_confirming(confirming: bool) -> void:
	_confirm_box.visible = confirming
	var signed_in := Sync.is_signed_in() and not confirming
	_rename_caption.visible = signed_in
	_name_field.visible = signed_in
	_rename_button.visible = signed_in
	_sign_out_button.visible = signed_in
	_delete_button.visible = signed_in


func _set_status(message: String) -> void:
	_status_label.text = message
	_status_label.visible = message != ""


func _on_profile_updated(_profile: Dictionary) -> void:
	_refresh_labels()
	if _renaming:
		_renaming = false
		_rename_button.disabled = false
		_name_field.text = ""
		_set_status("Username updated.")


func _on_request_failed(action: String, message: String) -> void:
	if action == "rename":
		_renaming = false
		_rename_button.disabled = false
		_set_status(message)
	elif action == "profile":
		_set_status(message)
	elif action == "delete":
		_set_status(message)
		_confirm_delete_button.disabled = false
		_cancel_delete_button.disabled = false
		_set_confirming(false)


func _on_signed_out() -> void:
	_go_to_menu()


func _on_rename_pressed() -> void:
	var new_name := _name_field.text.strip_edges()
	if not SyncLogic.is_valid_username(new_name):
		_set_status("Username must be %d-%d characters." % [GameConfig.USERNAME_MIN_LENGTH, GameConfig.USERNAME_MAX_LENGTH])
		return
	_renaming = true
	_rename_button.disabled = true
	_set_status("Saving...")
	Sync.rename(new_name)


func _on_sign_out_pressed() -> void:
	Sync.sign_out()


func _on_delete_pressed() -> void:
	_set_status("")
	_set_confirming(true)


func _on_cancel_delete_pressed() -> void:
	_set_confirming(false)


func _on_create_profile_pressed() -> void:
	get_tree().change_scene_to_file(SIGN_IN_SCENE)


## The gear icon opens Settings over this screen.
func _on_settings_pressed() -> void:
	_settings_overlay.show()


func _on_confirm_delete_pressed() -> void:
	_confirm_delete_button.disabled = true
	_cancel_delete_button.disabled = true
	_set_status("Deleting account...")
	Sync.delete_account()


func _on_back_pressed() -> void:
	_go_to_menu()


func _go_to_menu() -> void:
	get_tree().change_scene_to_file(MENU_SCENE)
