class_name SessionStore
extends RefCounted
## Reads and writes the signed-in session (tokens, username, email) in user://session.json.
## Kept apart from save.json so tokens never mix with gameplay data. Never log its contents.

const PATH := "user://session.json"
const KEYS := ["access_token", "refresh_token", "username", "email"]


## Returns {} when there is no usable session (missing, corrupt, or no access token).
static func load_session(path: String = PATH) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_warning("SessionStore: could not open session file: %s" % error_string(FileAccess.get_open_error()))
		return {}
	var json := JSON.new()
	var parse_error := json.parse(file.get_as_text())
	file.close()
	if parse_error != OK or typeof(json.data) != TYPE_DICTIONARY:
		push_warning("SessionStore: session file is corrupt; treating as signed out.")
		return {}

	var data: Dictionary = json.data
	var session := {}
	for key in KEYS:
		session[key] = str(data.get(key, ""))
	if session["access_token"] == "":
		return {}
	return session


static func save_session(session: Dictionary, path: String = PATH) -> bool:
	var data := {}
	for key in KEYS:
		data[key] = str(session.get(key, ""))
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_warning("SessionStore: could not write session file: %s" % error_string(FileAccess.get_open_error()))
		return false
	file.store_string(JSON.stringify(data))
	file.close()
	return true


static func clear_session(path: String = PATH) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
