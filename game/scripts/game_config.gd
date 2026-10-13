class_name GameConfig
extends RefCounted
## Central tuning values. Change numbers here, not in other scripts.

const COLS := 10
const ROWS := 20
const SPAWN_ORIGIN := Vector2i(3, 0)

# Points for clearing 0..4 lines at once, multiplied by the current level.
const LINE_POINTS: Array[int] = [0, 100, 300, 500, 800]
const LINES_PER_LEVEL := 10

# Seconds between automatic downward steps.
const BASE_FALL_INTERVAL := 0.8
const FALL_SPEEDUP := 0.85 # multiplier applied per level above 1
const MIN_FALL_INTERVAL := 0.08
const SOFT_DROP_INTERVAL := 0.04
const MAX_FRAME_DELTA := 0.25 # clamps long frames (e.g. after resuming)

# Hold-to-repeat for left/right buttons.
const MOVE_REPEAT_DELAY := 0.16
const MOVE_REPEAT_INTERVAL := 0.05

# Horizontal offsets tried when a rotation is blocked (simple wall kicks).
const ROTATION_KICKS: Array[Vector2i] = [
	Vector2i(0, 0), Vector2i(-1, 0), Vector2i(1, 0), Vector2i(-2, 0), Vector2i(2, 0),
]
