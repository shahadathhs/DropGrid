class_name GameController
extends RefCounted
## Game rules and flow: active piece, falling, landing (lock delay), holding,
## locking, scoring (combos, back-to-back, T-spins), levels, pause, game over.
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
signal hold_changed
signal game_over(final_score: int)
## Sprint (and other goal modes): the goal was reached while still playing.
signal run_finished(final_score: int)
signal pause_changed(is_paused: bool)
signal board_changed  ## anything visible changed; views should redraw

enum State { PLAYING, PAUSED, GAME_OVER }

var board := BoardModel.new()
var state := State.PLAYING
var mode := GameMode.new()
var score := 0
var lines := 0
var level := 1
## Level the run began at; the level never drops below it.
var start_level := 1
## Milliseconds of play since the run began (frozen while paused).
var elapsed_ms := 0
## Ultra only: milliseconds left on the clock.
var time_left_ms := int(GameMode.new(GameMode.Mode.ULTRA).time_limit() * 1000)
## True when a run ended because its goal was reached (sprint), not a top-out.
var goal_reached := false

var has_active := false
var active_type := 0
var active_rotation := 0
var active_position := Vector2i.ZERO
var next_type := 0
var soft_dropping := false

## Held piece type (PieceData.Type), or -1 while the hold slot is empty.
var hold_type := -1
## One hold per spawned piece: holding again before the next spawn is a no-op.
var can_hold := false

## The piece has touched down and is waiting out the lock delay.
var landing := false

var _bag: PieceBag
var _fall_timer := 0.0
var _lock_timer := 0.0
var _lock_resets := 0
## Upcoming piece types; _queue[0] is next_type. Refilled from the bag.
var _queue: Array[int] = []
## Consecutive line-clearing locks. -1 = the last lock cleared nothing.
var _combo := -1
## The previous clear was "difficult" (tetris or T-spin): enables back-to-back.
var _difficult_streak := false


## Pass a seed (>= 0) for a repeatable piece order, e.g. in tests. The mode
## shapes the end conditions (see GameMode); the falling rules stay the same.
func _init(seed_value: int = -1, start_level_value: int = 1, mode_value: GameMode = null) -> void:
	mode = mode_value if mode_value != null else GameMode.new()
	if mode.mode == GameMode.Mode.DAILY:
		seed_value = GameMode.daily_seed()
	start_level = maxi(1, start_level_value)
	level = start_level
	_bag = PieceBag.new(seed_value)
	next_type = _bag.next_piece()
	_fill_queue()
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


## The next `count` (at most NEXT_QUEUE_SIZE) pieces to spawn, current next first.
func next_queue(count: int = GameConfig.NEXT_QUEUE_SIZE) -> Array[int]:
	return _queue.slice(0, mini(count, GameConfig.NEXT_QUEUE_SIZE))


## Swap the active piece with the hold slot. One swap per spawned piece.
func hold() -> void:
	if state != State.PLAYING or not has_active or not can_hold:
		return
	var swapped := hold_type
	hold_type = active_type
	landing = false
	_lock_timer = 0.0
	_lock_resets = 0
	soft_dropping = false
	if swapped == -1:
		_spawn_next()
	else:
		_reset_active(swapped)
	can_hold = false  # one hold per spawned piece, even after the swap
	hold_changed.emit()


## Advance the fall timer or, while landing, the lock timer. Nothing happens
## unless the game is being played.
func advance(delta: float) -> void:
	if state != State.PLAYING or not has_active:
		return
	var step := minf(delta, GameConfig.MAX_FRAME_DELTA)
	elapsed_ms += int(step * 1000.0)
	if mode.time_limit() >= 0.0:
		var before := time_left_ms
		time_left_ms = maxi(0, time_left_ms - int(step * 1000.0))
		if before > 0 and time_left_ms == 0:
			_end_game()
			return
	if landing:
		_lock_timer += step
		if _lock_timer >= GameConfig.LOCK_DELAY:
			_lock_active()
		return
	_fall_timer += step
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
	_reset_lock_timer()
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
			_reset_lock_timer()
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
		if landing:
			landing = false
			_lock_timer = 0.0
			_lock_resets = 0
		board_changed.emit()
	else:
		landing = true
		_lock_timer = 0.0
		board_changed.emit()


func _reset_lock_timer() -> void:
	if landing and _lock_resets < GameConfig.MAX_LOCK_RESETS:
		_lock_timer = 0.0
		_lock_resets += 1


func _lock_active() -> void:
	var cells := active_cells()
	var local_cells := PieceData.cells(active_type, active_rotation)
	board.lock_cells(local_cells, active_position, PieceData.color_index(active_type))
	has_active = false
	landing = false
	piece_locked.emit(cells)

	var cleared := board.clear_full_rows()
	var count := cleared.size()
	if count > 0:
		var points := points_for_lines(count, level)
		var difficult := count == 4
		if _difficult_streak and difficult:
			points = int(points * GameConfig.BACK_TO_BACK_MULTIPLIER)
		_difficult_streak = difficult
		_combo += 1
		points += _combo * GameConfig.COMBO_BONUS * level
		score += points
		lines += count
		lines_cleared.emit(cleared, points)
		score_changed.emit(score)
		lines_changed.emit(lines)
		var new_level := level_for_run(start_level, lines)
		if new_level != level:
			level = new_level
			level_changed.emit(level)
		if mode.goal_lines() > 0 and lines >= mode.goal_lines():
			_finish_run()
			return
	else:
		_combo = -1
		# A lock that clears nothing does not break a back-to-back chain.
	board_changed.emit()
	_spawn_next()


func _spawn_next() -> void:
	_queue.pop_front()
	_fill_queue()
	_reset_active(next_type)
	next_type = _queue[0]


func _reset_active(type: int) -> void:
	active_type = type
	active_rotation = 0
	active_position = GameConfig.SPAWN_ORIGIN
	_fall_timer = 0.0
	_lock_timer = 0.0
	_lock_resets = 0
	landing = false
	can_hold = true
	if not board.can_place(PieceData.cells(active_type, active_rotation), active_position):
		_end_game()
		return
	has_active = true
	piece_spawned.emit()
	board_changed.emit()


func _fill_queue() -> void:
	while _queue.size() < GameConfig.NEXT_QUEUE_SIZE:
		_queue.append(_bag.next_piece())


## Sprint: the goal was reached. The run ends as a win, not a top-out.
func _finish_run() -> void:
	goal_reached = true
	has_active = false
	soft_dropping = false
	landing = false
	state = State.GAME_OVER
	board_changed.emit()
	run_finished.emit(score)


func _end_game() -> void:
	# Zen has no game over: the board sheds everything and play continues.
	if mode.is_zen():
		board.reset()
		board_changed.emit()
		_spawn_next()
		return
	goal_reached = false
	has_active = false
	soft_dropping = false
	landing = false
	state = State.GAME_OVER
	board_changed.emit()
	game_over.emit(score)
