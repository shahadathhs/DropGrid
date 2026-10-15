extends Control

const GAME_SCENE := "res://scenes/game.tscn"
const SIGN_IN_SCENE := "res://scenes/sign_in.tscn"
const PROFILE_SCENE := "res://scenes/profile.tscn"
const LEADERBOARD_SCENE := "res://scenes/leaderboard.tscn"
const LEVELS_SCENE := "res://scenes/levels.tscn"

@onready var _best_label: Label = %BestLabel
@onready var _account_button: Button = %AccountButton
@onready var _leaderboard_button: Button = %LeaderboardButton
@onready var _settings_overlay: Control = %SettingsOverlay


func _ready() -> void:
	_best_label.text = UiFormat.thousands(Save.best_score)
	# Guests see Sign in; signed-in players see their Profile instead.
	_account_button.text = "Profile" if Sync.is_signed_in() else "Sign in"
	# A build without an API URL is a plain offline game: no account or leaderboard entries.
	_account_button.visible = Sync.is_online_enabled()
	_leaderboard_button.visible = Sync.is_online_enabled()
	_settings_overlay.hide()
	_settings_overlay.closed.connect(func(): _settings_overlay.hide())


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file(GAME_SCENE)


func _on_levels_pressed() -> void:
	get_tree().change_scene_to_file(LEVELS_SCENE)


func _on_account_pressed() -> void:
	var scene := PROFILE_SCENE if Sync.is_signed_in() else SIGN_IN_SCENE
	get_tree().change_scene_to_file(scene)


func _on_leaderboard_pressed() -> void:
	get_tree().change_scene_to_file(LEADERBOARD_SCENE)


## Settings opens as a full-screen layer.
func _on_settings_pressed() -> void:
	_settings_overlay.show()
