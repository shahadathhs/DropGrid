extends GutTest
## Phase 1 gameplay depth: the next queue, hold, the landing lock delay with
## move resets, and the scoring depth (combo, back-to-back, T-spin).
##
## Seeds are chosen so the first spawned piece is the type the test needs
## (seed 6 starts an I piece, seed 2 starts a T piece).

const SEED_FIRST_I := 6
const SEED_FIRST_T := 2


func _game(first_piece_seed: int) -> GameController:
	return GameController.new(first_piece_seed)


func _locked(game: GameController) -> Array:
	var flag := [false]
	game.piece_locked.connect(func(_cells): flag[0] = true)
	return flag


func _drop_at(game: GameController, target_x: int, rotations: int) -> void:
	for _turn in rotations:
		game.rotate_piece()
	var dx := target_x - game.active_position.x
	while dx != 0:
		assert_true(game.move(1 if dx > 0 else -1))
		dx = target_x - game.active_position.x
	game.hard_drop()


func _fill_row_except(game: GameController, row: int, from_col: int, to_col: int) -> void:
	for x in GameConfig.COLS:
		if x < from_col or x > to_col:
			game.board.lock_cells([Vector2i(0, 0)], Vector2i(x, row), 1)


## Clear exactly one row using whatever piece is active: every rotation-0 shape
## has a flat bottom, so the rest of the row is pre-filled around its footprint.
func _clear_one_row_with_active(game: GameController) -> void:
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
	_drop_at(game, target, 0)


## Drop pieces in the left columns until the requested type is active.
func _drop_until_type(game: GameController, type: int) -> void:
	for _attempt in 12:
		if game.active_type == type:
			return
		_drop_at(game, 0, 0)
	assert_eq(game.active_type, type, "the bag never produced piece %d" % type)


# ── Next queue ────────────────────────────────────────────────────────


func test_next_queue_leads_with_next_type_and_keeps_three_entries() -> void:
	var game := _game(SEED_FIRST_I)
	var queue := game.next_queue()
	assert_eq(queue.size(), GameConfig.NEXT_QUEUE_SIZE)
	assert_eq(queue[0], game.next_type)


func test_queue_advances_after_a_lock() -> void:
	var game := _game(SEED_FIRST_I)
	var before := game.next_queue()
	game.hard_drop()
	assert_eq(game.next_queue()[0], game.next_type)
	assert_ne(game.next_queue()[0], before[0], "the queue should have moved forward")


# ── Hold ──────────────────────────────────────────────────────────────


func test_hold_stashes_the_piece_and_spawns_the_next_one() -> void:
	var game := _game(SEED_FIRST_I)
	var stashed := game.active_type
	game.hold()
	assert_eq(game.hold_type, stashed)
	assert_true(game.has_active, "holding without a stashed piece spawns the next")
	assert_ne(game.active_type, stashed, "the 7-bag never repeats inside one bag")


func test_a_second_hold_is_ignored_until_the_next_piece_spawns() -> void:
	var game := _game(SEED_FIRST_I)
	game.hold()
	var stashed := game.hold_type
	var active := game.active_type
	game.hold()
	assert_eq(game.hold_type, stashed, "the slot must not change")
	assert_eq(game.active_type, active, "the active piece must not change")


func test_hold_swaps_back_after_a_lock() -> void:
	var game := _game(SEED_FIRST_I)
	var first := game.active_type
	game.hold()
	game.hard_drop()
	assert_true(game.can_hold, "a new piece frees the hold slot")
	game.hold()
	assert_eq(game.active_type, first, "the swap should return the stashed piece")


# ── Landing (lock delay) ──────────────────────────────────────────────


func _land_on_floor(game: GameController) -> void:
	for _frame in 100:
		if game.landing:
			return
		game.advance(0.3)
	assert_true(game.landing, "the piece never touched down")


func test_a_landed_piece_waits_for_the_lock_delay_before_locking() -> void:
	var game := _game(SEED_FIRST_I)
	_land_on_floor(game)
	var locked := _locked(game)
	game.advance(GameConfig.LOCK_DELAY * 0.8)
	assert_false(locked[0], "the piece must still be there before the delay ends")
	game.advance(GameConfig.LOCK_DELAY)
	assert_true(locked[0], "the piece must lock once the delay passes")


func test_a_successful_move_resets_the_lock_timer() -> void:
	var game := _game(SEED_FIRST_I)
	_land_on_floor(game)
	var locked := _locked(game)
	game.advance(GameConfig.LOCK_DELAY * 0.8)
	assert_true(game.move(-1), "the piece should still slide along the floor")
	game.advance(GameConfig.LOCK_DELAY * 0.8)
	assert_false(locked[0], "the move reset the delay, so 0.8x is not enough")
	game.advance(GameConfig.LOCK_DELAY)
	assert_true(locked[0])


func test_lock_resets_stop_at_the_cap() -> void:
	var game := _game(SEED_FIRST_I)
	_land_on_floor(game)
	var locked := _locked(game)
	for _reset in GameConfig.MAX_LOCK_RESETS:
		var moved := game.move(-1) or game.move(1)
		assert_true(moved, "the piece should keep sliding while resets remain")
		game.advance(GameConfig.LOCK_DELAY * 0.5)  # reset each time, never reach the delay
	var moved := game.move(-1) or game.move(1)
	assert_true(moved)
	game.advance(GameConfig.LOCK_DELAY)
	assert_true(locked[0], "past the cap the move stops resetting the delay")


# ── Combo and back-to-back ────────────────────────────────────────────


func test_consecutive_clears_gain_the_combo_bonus() -> void:
	var game := _game(SEED_FIRST_I)
	_clear_one_row_with_active(game)  # combo 0: plain 100 points
	assert_eq(game.score, 100)

	_clear_one_row_with_active(game)  # combo 1: 100 + 50 * 1 * level 1
	assert_eq(game.score, 100 + 150)


func test_back_to_back_tetrises_score_one_and_a_half_times() -> void:
	var game := _game(SEED_FIRST_I)
	for row in range(GameConfig.ROWS - 4, GameConfig.ROWS):
		_fill_row_except(game, row, 9, 9)
	_drop_at(game, 7, 1)  # vertical I closes four rows: 800, combo 0
	assert_eq(game.score, 800)

	# Drop harmless pieces to the left: nothing clears, so the back-to-back
	# chain survives while the combo counter resets.
	_drop_until_type(game, PieceData.Type.I)

	for row in range(GameConfig.ROWS - 4, GameConfig.ROWS):
		_fill_row_except(game, row, 9, 9)
	_drop_at(game, 7, 1)  # second tetris in a chain: 800 * 1.5, combo resets to 0
	assert_eq(game.score, 800 + 1200)


func _land_t_in_slot(game: GameController) -> void:
	_fill_row_except(game, GameConfig.ROWS - 1, 4, 6)
	_land_on_floor(game)
