class_name GameController
extends RefCounted
## Game rules and flow: active piece, falling, locking, scoring, levels, pause, game over.
## Pure logic with signals; the scene (game.gd) drives it with advance(delta) and
## player actions, and views listen to the signals.

signal score_changed(score: int)
signal lines_changed(total_lines: int)
signal level_changed(level: int)
signal piece_spawned
signal piece_moved
signal piece_rotated
signal piece_locked(cells: Array[Vector2i])
signal lines_cleared(rows: Array[int], points: int)
signal game_over(final_score: int)
signal pause_changed(is_paused: bool)
signal board_changed  ## anything visible changed; views should redraw

enum State { PLAYING, PAUSED, GAME_OVER }

var board := BoardModel.new()
var state := State.PLAYING
var score := 0
var lines := 0
var level := 1
## Level the run began at; the level never drops below it.
var start_level := 1

var has_active := false
var active_type := 0
var active_rotation := 0
var active_position := Vector2i.ZERO
var next_type := 0
var soft_dropping := false

var _bag: PieceBag
var _fall_timer := 0.0


## Pass a seed (>= 0) for a repeatable piece order, e.g. in tests.
func _init(seed_value: int = -1, start_level_value: int = 1) -> void:
	start_level = maxi(1, start_level_value)
	level = start_level
	_bag = PieceBag.new(seed_value)
	next_type = _bag.next_piece()
	_spawn_next()


static func fall_interval(for_level: int) -> float:
	var interval := GameConfig.BASE_FALL_INTERVAL * pow(GameConfig.FALL_SPEEDUP, for_level - 1)
	return maxf(GameConfig.MIN_FALL_INTERVAL, interval)


## Points for clearing `count` lines at once: the table in GameConfig, times the level.
static func points_for_lines(count: int, for_level: int) -> int:
	return GameConfig.LINE_POINTS[clampi(count, 0, GameConfig.LINE_POINTS.size() - 1)] * for_level


## The one level rule: level 1 for the first 10 lines, then up one level every 10 lines.
static func level_for_lines(total_lines: int) -> int:
	@warning_ignore("integer_division")
	return total_lines / GameConfig.LINES_PER_LEVEL + 1


## Level during a run: the start level, or the line-based level once that is higher.
static func level_for_run(start: int, lines_this_game: int) -> int:
	return maxi(start, level_for_lines(lines_this_game))


## Advance the fall timer. Does nothing unless the game is being played.
func advance(delta: float) -> void:
	if state != State.PLAYING or not has_active:
		return
	_fall_timer += minf(delta, GameConfig.MAX_FRAME_DELTA)
	var interval := _current_interval()
	var steps := 0
	while _fall_timer >= interval and state == State.PLAYING and steps < 8:
		_fall_timer -= interval
		_step_down()
		steps += 1


func move(dx: int) -> bool:
	if state != State.PLAYING or not has_active:
		return false
	if not _try_shift(Vector2i(dx, 0)):
		return false
	piece_moved.emit()
	board_changed.emit()
	return true


func rotate_piece() -> bool:
	if state != State.PLAYING or not has_active:
		return false
	var new_rotation := (active_rotation + 1) % 4
	var new_cells := PieceData.cells(active_type, new_rotation)
	for kick in GameConfig.ROTATION_KICKS:
		if board.can_place(new_cells, active_position + kick):
			active_rotation = new_rotation
			active_position += kick
			piece_rotated.emit()
			board_changed.emit()
			return true
	return false


func set_soft_drop(enabled: bool) -> void:
	if state != State.PLAYING:
		enabled = false
	if enabled and not soft_dropping:
		_fall_timer = GameConfig.SOFT_DROP_INTERVAL  # step down right away
	soft_dropping = enabled


func hard_drop() -> void:
	if state != State.PLAYING or not has_active:
		return
	active_position.y += _drop_distance()
	_lock_active()


func set_paused(paused: bool) -> void:
	if state == State.GAME_OVER:
		return
	var new_state := State.PAUSED if paused else State.PLAYING
	if new_state == state:
		return
	state = new_state
	soft_dropping = false
	pause_changed.emit(paused)


## Board cells (absolute) occupied by the active piece; empty if none.
func active_cells() -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	if not has_active:
		return result
	for cell in PieceData.cells(active_type, active_rotation):
		result.append(cell + active_position)
	return result


## Where the active piece would land if dropped straight down.
func ghost_cells() -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	if not has_active:
		return result
	var drop := _drop_distance()
	for cell in PieceData.cells(active_type, active_rotation):
		result.append(cell + active_position + Vector2i(0, drop))
	return result


func _current_interval() -> float:
	var interval := fall_interval(level)
	if soft_dropping:
		interval = minf(interval, GameConfig.SOFT_DROP_INTERVAL)
	return interval


func _drop_distance() -> int:
	var local_cells := PieceData.cells(active_type, active_rotation)
	var distance := 0
	while board.can_place(local_cells, active_position + Vector2i(0, distance + 1)):
		distance += 1
	return distance


func _try_shift(offset: Vector2i) -> bool:
	var local_cells := PieceData.cells(active_type, active_rotation)
	if not board.can_place(local_cells, active_position + offset):
		return false
	active_position += offset
	return true


func _step_down() -> void:
	if _try_shift(Vector2i(0, 1)):
		board_changed.emit()
	else:
		_lock_active()


func _lock_active() -> void:
	var cells := active_cells()
	var local_cells := PieceData.cells(active_type, active_rotation)
	board.lock_cells(local_cells, active_position, PieceData.color_index(active_type))
	has_active = false
	piece_locked.emit(cells)

	var cleared := board.clear_full_rows()
	if not cleared.is_empty():
		var points := points_for_lines(cleared.size(), level)
		score += points
		lines += cleared.size()
		lines_cleared.emit(cleared, points)
		score_changed.emit(score)
		lines_changed.emit(lines)
		var new_level := level_for_run(start_level, lines)
		if new_level != level:
			level = new_level
			level_changed.emit(level)
	board_changed.emit()
	_spawn_next()


func _spawn_next() -> void:
	active_type = next_type
	next_type = _bag.next_piece()
	active_rotation = 0
	active_position = GameConfig.SPAWN_ORIGIN
	_fall_timer = 0.0
	if not board.can_place(PieceData.cells(active_type, active_rotation), active_position):
		_end_game()
		return
	has_active = true
	piece_spawned.emit()
	board_changed.emit()


func _end_game() -> void:
	has_active = false
	soft_dropping = false
	state = State.GAME_OVER
	board_changed.emit()
	game_over.emit(score)
