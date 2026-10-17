extends Node
## Autoload singleton ("Sync"): the only code that talks to the network.
## Owns the session (tokens in user://session.json), one request queue, and one
## retry timer. Gameplay never waits on it: results arrive as signals, and
## background failures stay silent.

signal signed_in
signal signed_out
signal profile_updated(profile: Dictionary)
signal leaderboard_ready(entries: Array)
## action is one of: "register", "sign_in", "rename", "profile", "delete", "leaderboard", "sync".
signal request_failed(action: String, message: String)

## Where the session lives. Tests point it at a temp file.
var session_path := SessionStore.PATH

var _session: Dictionary = {}
var _http: HTTPRequest
var _retry_timer: Timer
## Requests run one at a time, first in first out. That stops two calls from
## refreshing the token at the same moment.
var _queue: Array[Dictionary] = []
var _busy := false
## True while a stat push is queued, so we never queue two at once.
var _sync_queued := false
var _failures := 0


func _ready() -> void:
	_http = HTTPRequest.new()
	add_child(_http)
	_http.request_completed.connect(_on_request_completed)

	_retry_timer = Timer.new()
	_retry_timer.one_shot = true
	add_child(_retry_timer)
	_retry_timer.timeout.connect(_on_retry_timer_timeout)

	reload_session()
	if is_signed_in():
		# App start with a session: send anything pending, then refresh the profile.
		push_stats()
		fetch_profile()


func _notification(what: int) -> void:
	# Going to the background is a good moment to send stats. The request may not
	# finish before the OS suspends the app; the next start retries via pending_sync.
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_APPLICATION_PAUSED:
		push_stats()


func reload_session() -> void:
	_session = SessionStore.load_session(session_path)


func is_signed_in() -> bool:
	return str(_session.get("access_token", "")) != ""


func username() -> String:
	return str(_session.get("username", ""))


func email() -> String:
	return str(_session.get("email", ""))


## False when this build has no API URL: no requests are made and the UI hides account features.
func is_online_enabled() -> bool:
	return SyncLogic.is_online_enabled(GameConfig.api_base_url())


## Number of requests waiting or in flight. Lets tests check that guests send nothing.
func queued_request_count() -> int:
	return _queue.size()


# ---------------------------------------------------------------------------
# Public actions. Each one reports back through a signal.
# ---------------------------------------------------------------------------


func register(email_text: String, password: String, username_text: String) -> void:
	var body := {"email": email_text, "password": password, "username": username_text}
	_enqueue(
		"register",
		HTTPClient.METHOD_POST,
		"/auth/register",
		body,
		false,
		_on_auth_finished.bind(email_text, username_text, "register")
	)


func sign_in(email_text: String, password: String) -> void:
	var body := {"email": email_text, "password": password}
	_enqueue(
		"sign_in",
		HTTPClient.METHOD_POST,
		"/auth/login",
		body,
		false,
		_on_auth_finished.bind(email_text, "", "sign_in")
	)


func sign_out() -> void:
	_clear_session()


func delete_account() -> void:
	if not is_signed_in():
		return
	_enqueue("delete", HTTPClient.METHOD_DELETE, "/players/me", null, true, _on_delete_finished)


func rename(new_username: String) -> void:
	if not is_signed_in():
		request_failed.emit("rename", "Sign in to change your username.")
		return
	_enqueue(
		"rename",
		HTTPClient.METHOD_PATCH,
		"/players/me",
		{"username": new_username},
		true,
		_on_rename_finished
	)


func fetch_profile() -> void:
	if not is_signed_in():
		return
	_enqueue("profile", HTTPClient.METHOD_GET, "/players/me", null, true, _on_profile_finished)


func fetch_leaderboard() -> void:
	_enqueue(
		"leaderboard", HTTPClient.METHOD_GET, "/leaderboard", null, false, _on_leaderboard_finished
	)


## Sends local stats if there is a session and something changed. Called after each game,
## on background, and on start. Does nothing for guests, so guest play makes no requests.
func push_stats() -> void:
	_send_stats(false)


# ---------------------------------------------------------------------------
# Stat sync and retry
# ---------------------------------------------------------------------------


func _send_stats(force: bool) -> void:
	if not is_online_enabled() or not is_signed_in() or _sync_queued:
		return
	if not force and not Save.pending_sync:
		return
	# While a retry is scheduled, wait for the timer instead of hammering the server.
	if not force and not _retry_timer.is_stopped():
		return
	_sync_queued = true
	var revision := Save.stats_revision
	var body := Save.stats()
	body["categories"] = Save.category_payload()
	_enqueue("sync", HTTPClient.METHOD_POST, "/sync", body, true, _on_sync_finished.bind(revision))


func _on_sync_finished(code: int, data: Dictionary, revision: int) -> void:
	_sync_queued = false
	if code == 200:
		_failures = 0
		_retry_timer.stop()
		_apply_profile(data, revision)
	elif SyncLogic.is_retryable(code):
		_failures += 1
		if _retry_timer.is_stopped():
			_retry_timer.start(SyncLogic.backoff_delay(_failures))
		request_failed.emit("sync", SyncLogic.error_message(code, data))


func _on_retry_timer_timeout() -> void:
	_send_stats(false)


## Merges the server profile into the save (max per stat and per category). The
## revision check keeps pending_sync true if a run was recorded while the
## request was in flight.
func _apply_profile(profile: Dictionary, revision: int = -1) -> void:
	var merged := SyncLogic.merge_stats(Save.stats(), profile)
	merged["category_bests"] = SyncLogic.merge_category_bests(
		Save.stats().get("category_bests", {}), profile.get("category_bests", {})
	)
	Save.apply_merged_stats(merged)
	if revision >= 0:
		Save.mark_synced(revision)
	if profile.has("username"):
		_session["username"] = str(profile["username"])
	if profile.has("email"):
		_session["email"] = str(profile["email"])
	if profile.has("username") or profile.has("email"):
		_save_session()
	profile_updated.emit(profile)


# ---------------------------------------------------------------------------
# Callbacks for each action
# ---------------------------------------------------------------------------


func _on_auth_finished(
	code: int, data: Dictionary, email_text: String, username_text: String, action: String
) -> void:
	if (code != 200 and code != 201) or not _has_tokens(data):
		_report(action, code, data)
		return
	_session = {
		"access_token": str(data["access_token"]),
		"refresh_token": str(data["refresh_token"]),
		"username": username_text,
		"email": email_text,
	}
	_save_session()
	signed_in.emit()
	# Push local stats first, then fetch the merged profile (spec order).
	_send_stats(true)
	fetch_profile()


func _on_profile_finished(code: int, data: Dictionary) -> void:
	if code == 200:
		_apply_profile(data)
	else:
		_report("profile", code, data)


func _on_rename_finished(code: int, data: Dictionary) -> void:
	if code == 200:
		_apply_profile(data)
	else:
		_report("rename", code, data)


func _on_delete_finished(code: int, data: Dictionary) -> void:
	if code == 200 or code == 204:
		_clear_session()
	else:
		_report("delete", code, data)


func _on_leaderboard_finished(code: int, data: Dictionary) -> void:
	if code == 200 and typeof(data.get("entries")) == TYPE_ARRAY:
		leaderboard_ready.emit(data["entries"])
	else:
		_report("leaderboard", code, data)


func _report(action: String, code: int, data: Dictionary) -> void:
	request_failed.emit(action, SyncLogic.error_message(code, data))


# ---------------------------------------------------------------------------
# Request queue and token refresh
# ---------------------------------------------------------------------------


func _enqueue(
	action: String, method: int, path: String, body: Variant, auth: bool, on_done: Callable
) -> void:
	if not is_online_enabled():
		request_failed.emit(action, "Online features are not available in this build.")
		return
	(
		_queue
		. append(
			{
				"action": action,
				"method": method,
				"path": path,
				"body": body,
				"auth": auth,
				"on_done": on_done,
				"retried": false,
				"is_refresh": false,
			}
		)
	)
	# Deferred so a request is never started from inside another request's signal.
	call_deferred("_pump")


func _pump() -> void:
	if _busy or _queue.is_empty():
		return
	var job: Dictionary = _queue[0]
	if job["auth"] and not is_signed_in():
		_finish_job(401, {})
		return

	_busy = true
	var headers := PackedStringArray(["Content-Type: application/json"])
	if job["auth"]:
		headers.append("Authorization: Bearer %s" % _session["access_token"])
	var body_text := "" if job["body"] == null else JSON.stringify(job["body"])
	var err := _http.request(
		GameConfig.api_base_url() + job["path"], headers, job["method"], body_text
	)
	if err != OK:
		_finish_job(0, {})


func _on_request_completed(
	result: int, code: int, _headers: PackedStringArray, body: PackedByteArray
) -> void:
	if result != HTTPRequest.RESULT_SUCCESS:
		code = 0
	var data := _parse_body(body)
	var job: Dictionary = _queue[0]

	if job["is_refresh"]:
		_on_refresh_finished(code, data)
		return

	if code == 401 and job["auth"]:
		if _has_refresh_token() and not job["retried"]:
			# Access token expired: refresh once, then resend this same request.
			job["retried"] = true
			_queue.push_front(_make_refresh_job())
			_busy = false
			call_deferred("_pump")
			return
		if not _has_refresh_token():
			_clear_session()

	_finish_job(code, data)


func _make_refresh_job() -> Dictionary:
	return {
		"action": "refresh",
		"method": HTTPClient.METHOD_POST,
		"path": "/auth/refresh",
		"body": {"refresh_token": str(_session["refresh_token"])},
		"auth": false,
		"on_done": Callable(),
		"retried": false,
		"is_refresh": true,
	}


func _on_refresh_finished(code: int, data: Dictionary) -> void:
	_queue.pop_front()  # the refresh job itself
	_busy = false
	if code == 200 and _has_tokens(data):
		_session["access_token"] = str(data["access_token"])
		_session["refresh_token"] = str(data["refresh_token"])
		_save_session()
		call_deferred("_pump")  # resend the original request with the new token
	elif code == 401:
		# The refresh token is no good, so the user is a guest now. Fail every
		# queued signed-in request and keep the local stats untouched.
		_clear_session()
		_fail_queued_auth_jobs()
		call_deferred("_pump")
	else:
		# Network or server trouble: keep the session and fail only the original request.
		_finish_job(code, data)


func _fail_queued_auth_jobs() -> void:
	var index := 0
	while index < _queue.size():
		if _queue[index]["auth"]:
			var job: Dictionary = _queue.pop_at(index)
			job["on_done"].call(401, {})
		else:
			index += 1


func _finish_job(code: int, data: Dictionary) -> void:
	var job: Dictionary = _queue.pop_front()
	_busy = false
	job["on_done"].call(code, data)
	call_deferred("_pump")


func _parse_body(body: PackedByteArray) -> Dictionary:
	var json := JSON.new()
	if json.parse(body.get_string_from_utf8()) == OK and typeof(json.data) == TYPE_DICTIONARY:
		return json.data
	return {}


func _has_tokens(data: Dictionary) -> bool:
	return str(data.get("access_token", "")) != "" and str(data.get("refresh_token", "")) != ""


func _has_refresh_token() -> bool:
	return str(_session.get("refresh_token", "")) != ""


func _save_session() -> void:
	# An in-flight response may arrive after sign-out; never write an empty session back.
	if is_signed_in():
		SessionStore.save_session(_session, session_path)


func _clear_session() -> void:
	_session = {}
	SessionStore.clear_session(session_path)
	_retry_timer.stop()
	_failures = 0
	signed_out.emit()
