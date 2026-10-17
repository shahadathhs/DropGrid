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


## The API base URL for this build (feature-tag overrides resolve automatically).
static func api_base_url() -> String:
	return str(ProjectSettings.get_setting(API_URL_SETTING, "")).strip_edges()
