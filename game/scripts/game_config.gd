class_name GameConfig
extends RefCounted
## Central tuning values. Change numbers here, not in other scripts.

const COLS := 10
const ROWS := 20
const SPAWN_ORIGIN := Vector2i(3, 0)

# Points for clearing 0..4 lines at once, multiplied by the current level.
const LINE_POINTS: Array[int] = [0, 100, 300, 500, 800]
const LINES_PER_LEVEL := 10
## Highest level the levels screen offers as a start level.
const MAX_START_LEVEL := 10

# Seconds between automatic downward steps.
const BASE_FALL_INTERVAL := 0.8
const FALL_SPEEDUP := 0.85  # multiplier applied per level above 1
const MIN_FALL_INTERVAL := 0.08
const SOFT_DROP_INTERVAL := 0.04
const MAX_FRAME_DELTA := 0.25  # clamps long frames (e.g. after resuming)

# Lock delay: a landed piece waits this long before locking. A successful move
# or rotation resets the timer, at most MAX_LOCK_RESETS times per piece.
const LOCK_DELAY := 0.5
const MAX_LOCK_RESETS := 15

# HUD previews: how many upcoming pieces the queue shows.
const NEXT_QUEUE_SIZE := 3

# Scoring depth. Combo bonus is COMBO_BONUS * combo * level, where combo counts
# consecutive line-clearing locks (first clear = combo 0 = no bonus). A tetris
# right after another difficult clear multiplies by BACK_TO_BACK_MULTIPLIER.
const COMBO_BONUS := 50
const BACK_TO_BACK_MULTIPLIER := 1.5

# Modes. Sprint ends at GOAL_LINES cleared; Ultra ends when the time limit is
# up. Zen has no game over: the board sheds its top rows instead. Daily plays
# by marathon rules on a seed derived from the UTC date.
const SPRINT_GOAL_LINES := 40
const ULTRA_TIME_LIMIT := 120.0

# Hold-to-repeat for left/right buttons.
const MOVE_REPEAT_DELAY := 0.16
const MOVE_REPEAT_INTERVAL := 0.05

# Horizontal offsets tried when a rotation is blocked (simple wall kicks).
const ROTATION_KICKS: Array[Vector2i] = [
	Vector2i(0, 0),
	Vector2i(-1, 0),
	Vector2i(1, 0),
	Vector2i(-2, 0),
	Vector2i(2, 0),
]

# Sync server. The URL is a project setting so each build can differ:
# dropgrid/network/api_base_url in project.godot, with a ".release" feature-tag
# override. Android emulators reach the host machine at 10.0.2.2, so use
# http://10.0.2.2:8000/v1 there. A physical phone needs the computer's LAN IP,
# for example http://192.168.1.20:8000/v1. An empty URL turns online features off.
const API_URL_SETTING := "dropgrid/network/api_base_url"
const USERNAME_MIN_LENGTH := 3
const USERNAME_MAX_LENGTH := 20
const PASSWORD_MIN_LENGTH := 8

# Retry delays for failed stat pushes: 5s, 10s, 20s, ... up to 5 minutes.
const BACKOFF_BASE_SECONDS := 5.0
const BACKOFF_MAX_SECONDS := 300.0


## The API base URL for this build. Feature-tag overrides (.release, .web) only apply through
## get_setting_with_override; plain get_setting returns the base value.
static func api_base_url() -> String:
	return str(ProjectSettings.get_setting_with_override(API_URL_SETTING)).strip_edges()


## True in the browser build: a guest-only demo that never stores or sends anything.
static func is_web() -> bool:
	return OS.has_feature("web")
