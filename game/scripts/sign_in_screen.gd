extends Control
## Sign-in and create-account screen. One form with a toggle between the two modes.
## The requests go through the Sync autoload; this screen only waits for its signals.

const MENU_SCENE := "res://scenes/main_menu.tscn"

@onready var _title: Label = %Title
@onready var _heading: Label = %Heading
@onready var _heading_accent: Label = %HeadingAccent
@onready var _email_field: LineEdit = %EmailField
@onready var _password_field: LineEdit = %PasswordField
@onready var _username_block: Control = %UsernameBlock
@onready var _username_field: LineEdit = %UsernameField
@onready var _status_panel: Control = %StatusPanel
@onready var _status_label: Label = %StatusLabel
@onready var _submit_button: Button = %SubmitButton
@onready var _sign_in_tab: Button = %SignInTab
@onready var _create_tab: Button = %CreateTab

var _creating_account := false
## True while a request is in flight; the form is locked until it answers.
var _waiting := false


func _ready() -> void:
	Sync.signed_in.connect(_on_signed_in)
	Sync.request_failed.connect(_on_request_failed)
	_set_mode(false)


func _set_mode(creating: bool) -> void:
	_creating_account = creating
	_title.text = "Create account" if creating else "Sign in"
	_heading.text = "Save your" if creating else "Welcome"
	_heading_accent.text = "progress." if creating else "back."
	_username_block.visible = creating
	_sign_in_tab.button_pressed = not creating
	_create_tab.button_pressed = creating
	_refresh_submit_label()
	_set_status("")


func _refresh_submit_label() -> void:
	if _waiting:
		_submit_button.text = "Creating account..." if _creating_account else "Signing in..."
	else:
		_submit_button.text = "Create account" if _creating_account else "Sign in"


## The error box only shows when there is a message.
func _set_status(message: String) -> void:
	_status_label.text = message
	_status_panel.visible = message != ""


func _set_form_enabled(enabled: bool) -> void:
	_email_field.editable = enabled
	_password_field.editable = enabled
	_username_field.editable = enabled
	_submit_button.disabled = not enabled
	_sign_in_tab.disabled = not enabled
	_create_tab.disabled = not enabled


## The two segment tabs. While a request is running the tabs are locked, so keep the current mode.
func _on_sign_in_tab_pressed() -> void:
	_switch_mode(false)


func _on_create_tab_pressed() -> void:
	_switch_mode(true)


func _switch_mode(creating: bool) -> void:
	_set_mode(creating if not _waiting else _creating_account)


func _on_submit_pressed() -> void:
	if _waiting:
		return
	var email := _email_field.text.strip_edges()
	var password := _password_field.text
	# Check the inputs here first so the player gets an instant, specific message.
	if not SyncLogic.is_valid_email(email):
		_set_status("Enter a valid email address.")
		return
	if not SyncLogic.is_valid_password(password):
		_set_status("Password must be at least %d characters." % GameConfig.PASSWORD_MIN_LENGTH)
		return

	if _creating_account:
		var username := _username_field.text.strip_edges()
		if not SyncLogic.is_valid_username(username):
			_set_status("Username must be %d-%d characters." % [GameConfig.USERNAME_MIN_LENGTH, GameConfig.USERNAME_MAX_LENGTH])
			return
		_start_waiting()
		Sync.register(email, password, username)
	else:
		_start_waiting()
		Sync.sign_in(email, password)


func _start_waiting() -> void:
	_waiting = true
	_set_form_enabled(false)
	_set_status("")
	_refresh_submit_label()


func _stop_waiting() -> void:
	_waiting = false
	_set_form_enabled(true)
	_refresh_submit_label()


func _on_signed_in() -> void:
	if _waiting:
		get_tree().change_scene_to_file(MENU_SCENE)


func _on_request_failed(action: String, message: String) -> void:
	if not _waiting or (action != "register" and action != "sign_in"):
		return
	_stop_waiting()
	_set_status(message)


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file(MENU_SCENE)
