extends GutTest
## Mode rules: sprint's 40-line goal, ultra's clock, zen's self-clearing board,
## and the daily seed that gives every player the same piece order.


func _game(mode: GameMode) -> GameController:
	return GameController.new(1, 1, mode)


func _fill_row_except(game: GameController, row: int, from_col: int, to_col: int) -> void:
	for x in GameConfig.COLS:
		if x < from_col or x > to_col:
			game.board.lock_cells([Vector2i(0, 0)], Vector2i(x, row), 1)


## Rotates, moves the active piece to column target_x, and hard drops it.
func _drop_at(game: GameController, target_x: int, rotations: int) -> void:
	for _turn in rotations:
		game.rotate_piece()
	var dx := target_x - game.active_position.x
	# Bounded, so a blocked move fails the test instead of looping forever.
	var steps := 0
	while dx != 0 and steps < GameConfig.COLS:
		assert_true(
			game.move(1 if dx > 0 else -1), "piece could not move toward column %d" % target_x
		)
		dx = target_x - game.active_position.x
		steps += 1
	game.hard_drop()


## Clears one row with whatever piece is active (see test_gameplay_depth).
func _clear_one_row(game: GameController) -> void:
	var cells := PieceData.cells(game.active_type, 0)
	var bottom := 0
	for c in cells:
		bottom = maxi(bottom, c.y)
	var footprint: Array[int] = []
	for c in cells:
		if c.y == bottom:
			footprint.append(c.x)
	var target := -mini(footprint.min(), 0)
	for x in GameConfig.COLS:
		if not footprint.has(x - target):
			game.board.lock_cells([Vector2i(0, 0)], Vector2i(x, GameConfig.ROWS - 1), 1)
	var dx := target - game.active_position.x
	while dx != 0:
		assert_true(game.move(1 if dx > 0 else -1))
		dx = target - game.active_position.x
	game.hard_drop()


func test_marathon_has_no_goal_and_no_clock() -> void:
	var game := _game(GameMode.new(GameMode.Mode.MARATHON))
	assert_eq(game.mode.goal_lines(), -1)
	assert_eq(game.mode.time_limit(), -1.0)
	assert_eq(game.mode.id(), "marathon")
	assert_false(game.goal_reached)


func test_sprint_finishes_at_forty_lines_as_a_win() -> void:
	var game := _game(GameMode.new(GameMode.Mode.SPRINT))
	var finished := [false]
	game.run_finished.connect(func(_score): finished[0] = true)
	# Ten self-cleaning tetrises (a vertical I leaves nothing behind) = 40 lines.
	for _round in GameConfig.SPRINT_GOAL_LINES / 4:
		for row in range(GameConfig.ROWS - 4, GameConfig.ROWS):
			_fill_row_except(game, row, 9, 9)
		_drop_at(game, 7, 1)
	assert_true(finished[0], "sprint must fire run_finished at the goal")
	assert_eq(game.lines, GameConfig.SPRINT_GOAL_LINES)
	assert_eq(game.state, GameController.State.GAME_OVER)
	assert_true(game.goal_reached, "reaching the goal is a win, not a top-out")


func test_ultra_ends_when_the_clock_hits_zero() -> void:
	var game := _game(GameMode.new(GameMode.Mode.ULTRA))
	assert_eq(game.time_left_ms, int(GameConfig.ULTRA_TIME_LIMIT * 1000))
	var ended := [false]
	game.game_over.connect(func(_score): ended[0] = true)
	game.advance(1.0)  # a full second off the clock; the run continues
	assert_true(game.has_active)
	assert_lt(game.time_left_ms, int(GameConfig.ULTRA_TIME_LIMIT * 1000))
	game.time_left_ms = 30
	game.advance(0.05)
	assert_true(ended[0], "ultra must end when the clock runs out")
	assert_false(game.goal_reached)


func test_elapsed_ms_counts_play_time_but_not_pause() -> void:
	var game := _game(GameMode.new(GameMode.Mode.MARATHON))
	game.advance(1.0)
	var after_play := game.elapsed_ms
	assert_gt(after_play, 0)
	game.set_paused(true)
	game.advance(5.0)
	assert_eq(game.elapsed_ms, after_play, "paused time must not count")


func test_zen_sheds_the_board_instead_of_ending() -> void:
	var game := _game(GameMode.new(GameMode.Mode.ZEN))
	# Fill the spawn area completely: a marathon run would end here.
	for y in 4:
		for x in GameConfig.COLS:
			game.board.lock_cells([Vector2i(0, 0)], Vector2i(x, y), 1)
	game.hard_drop()  # locks a piece and tries to spawn into a full board
	assert_eq(game.state, GameController.State.PLAYING, "zen has no game over")
	assert_true(game.has_active, "zen respawns after the shed")


func test_daily_players_share_one_seed_for_the_whole_utc_day() -> void:
	var a := _game(GameMode.new(GameMode.Mode.DAILY))
	var b := _game(GameMode.new(GameMode.Mode.DAILY))
	assert_eq(a.active_type, b.active_type)
	assert_eq(a.next_type, b.next_type)
	# And the seed is the plain UTC date, so it changes once per day.
	var date := Time.get_datetime_dict_from_unix_time(int(Time.get_unix_time_from_system()))
	assert_eq(GameMode.daily_seed(), date.year * 10000 + date.month * 100 + date.day)


func test_mode_lookup_by_id() -> void:
	assert_eq(GameMode.from_id("sprint").mode, GameMode.Mode.SPRINT)
	assert_eq(GameMode.from_id("daily").mode, GameMode.Mode.DAILY)
	assert_eq(GameMode.from_id("nonsense").mode, GameMode.Mode.MARATHON)
