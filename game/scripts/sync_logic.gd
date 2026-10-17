class_name SyncLogic
extends RefCounted
## Pure helpers for the sync client: stat merging, retry delays, error text, and
## input checks. No HTTP and no autoloads here, so they can be unit-tested directly.

const STAT_KEYS := ["best_score", "total_lines", "games_played"]


## Online features exist only when the build has an API URL. An empty URL (the release
## default until a server is configured) means a clean offline game.
static func is_online_enabled(api_url: String) -> bool:
	return api_url.strip_edges() != ""


## Both sides keep monotonic counters, so the merged value is the larger one per stat.
static func merge_stats(local: Dictionary, server: Dictionary) -> Dictionary:
	var merged := {}
	for key in STAT_KEYS:
		merged[key] = maxi(int(local.get(key, 0)), int(server.get(key, 0)))
	return merged


## Merges the server's per-category bests into the local ones. Score categories
## take the higher score, sprint the lower duration; a daily best competes only
## within its own UTC date (the newer date wins outright).
static func merge_category_bests(local: Dictionary, server: Dictionary) -> Dictionary:
	var merged := local.duplicate(true)
	for category in server:
		if not category in SaveManager.SCORE_CATEGORIES:
			continue
		if typeof(server[category]) != TYPE_DICTIONARY:
			continue
		var incoming: Dictionary = server[category]
		var current: Dictionary = merged.get(category, {})
		if current.is_empty():
			merged[category] = incoming
			continue
		if category == "daily":
			if str(incoming.get("date", "")) > str(current.get("date", "")):
				merged[category] = incoming
			elif str(incoming.get("date", "")) == str(current.get("date", "")):
				if int(incoming.get("score", 0)) > int(current.get("score", 0)):
					merged[category] = incoming
			continue
		if category == "sprint":
			if int(incoming.get("duration_ms", 1 << 30)) < int(current.get("duration_ms", 1 << 30)):
				merged[category] = incoming
			continue
		if int(incoming.get("score", 0)) > int(current.get("score", 0)):
			merged[category] = incoming
	return merged


## Seconds to wait after the nth failure in a row: 5, 10, 20, ... capped at 300.
static func backoff_delay(failures: int) -> float:
	if failures <= 0:
		return 0.0
	var delay := GameConfig.BACKOFF_BASE_SECONDS * pow(2.0, failures - 1)
	return minf(delay, GameConfig.BACKOFF_MAX_SECONDS)


## No response (code 0) or a server error is worth retrying later.
## Client errors such as 401 or 409 would fail again, so they are not retried.
static func is_retryable(code: int) -> bool:
	return code == 0 or code >= 500


## A short message for the player. Prefers the server's {"detail": ...} text.
static func error_message(code: int, data: Dictionary) -> String:
	var detail: Variant = data.get("detail", "")
	if typeof(detail) == TYPE_STRING and detail != "":
		return detail
	match code:
		0:
			return "Couldn't reach the server. Try again later."
		401:
			return "Please sign in again."
		409:
			return "That email or username is already taken."
	return "Something went wrong. Try again."


static func is_valid_email(text: String) -> bool:
	var at := text.find("@")
	var dot := text.find(".", at)
	return at > 0 and dot > at + 1 and dot < text.length() - 1


static func is_valid_username(text: String) -> bool:
	return (
		text.length() >= GameConfig.USERNAME_MIN_LENGTH
		and text.length() <= GameConfig.USERNAME_MAX_LENGTH
	)


static func is_valid_password(text: String) -> bool:
	return text.length() >= GameConfig.PASSWORD_MIN_LENGTH
