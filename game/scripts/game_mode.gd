class_name GameMode
extends RefCounted
## The playable modes. A mode configures how a run ends and which leaderboard
## category its result belongs to; the falling-block rules stay the same.

enum Mode { MARATHON, SPRINT, ULTRA, DAILY, ZEN }

## Leaderboard categories. Zen earns nothing: it is the no-pressure mode.
const CATEGORIES: Array[String] = ["marathon", "sprint", "ultra", "daily"]

var mode: Mode = Mode.MARATHON


func _init(mode_value: Mode = Mode.MARATHON) -> void:
	mode = mode_value


func id() -> String:
	match mode:
		Mode.SPRINT:
			return "sprint"
		Mode.ULTRA:
			return "ultra"
		Mode.DAILY:
			return "daily"
		Mode.ZEN:
			return "zen"
	return "marathon"


func display_name() -> String:
	match mode:
		Mode.SPRINT:
			return "Sprint"
		Mode.ULTRA:
			return "Ultra"
		Mode.DAILY:
			return "Daily"
		Mode.ZEN:
			return "Zen"
	return "Marathon"


## One-line description for the mode picker.
func tagline() -> String:
	match mode:
		Mode.SPRINT:
			return "Clear 40 lines as fast as you can."
		Mode.ULTRA:
			return "Two minutes. Best score wins."
		Mode.DAILY:
			return "Today's fixed piece order. Everyone plays the same."
		Mode.ZEN:
			return "No game over. The board clears itself."
	return "Clear lines, level up, survive."


## Sprint ends when this many lines are cleared.
func goal_lines() -> int:
	return GameConfig.SPRINT_GOAL_LINES if mode == Mode.SPRINT else -1


## Ultra ends when this much time (seconds) has passed. -1 = untimed.
func time_limit() -> float:
	return GameConfig.ULTRA_TIME_LIMIT if mode == Mode.ULTRA else -1.0


## Zen never ends in a game over; the board sheds its top instead.
func is_zen() -> bool:
	return mode == Mode.ZEN


## Every player gets the same piece order on the same UTC day.
static func daily_seed() -> int:
	var days := Time.get_unix_time_from_system() / 86400.0
	return int(floor(days))


static func daily_date() -> String:
	var unix := Time.get_unix_time_from_system()
	var date := Time.get_datetime_dict_from_unix_time(int(unix))
	return "%04d-%02d-%02d" % [date.year, date.month, date.day]


static func from_id(mode_id: String) -> GameMode:
	match mode_id:
		"sprint":
			return GameMode.new(Mode.SPRINT)
		"ultra":
			return GameMode.new(Mode.ULTRA)
		"daily":
			return GameMode.new(Mode.DAILY)
		"zen":
			return GameMode.new(Mode.ZEN)
	return GameMode.new(Mode.MARATHON)
