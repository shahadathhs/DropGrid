extends GutTest

var board: BoardModel


func before_each() -> void:
	board = BoardModel.new(4, 4)


func test_starts_empty() -> void:
	for y in 4:
		for x in 4:
			assert_eq(board.get_cell(x, y), BoardModel.EMPTY)


func test_can_place_rejects_outside_board() -> void:
	var cells: Array[Vector2i] = [Vector2i(0, 0)]
	assert_false(board.can_place(cells, Vector2i(-1, 0)), "left of board")
	assert_false(board.can_place(cells, Vector2i(4, 0)), "right of board")
	assert_false(board.can_place(cells, Vector2i(0, 4)), "below board")
	assert_true(board.can_place(cells, Vector2i(0, 0)), "inside board")


func test_can_place_rejects_occupied_cell() -> void:
	board.lock_cells([Vector2i(0, 0)], Vector2i(1, 1), 1)
	assert_false(board.can_place([Vector2i(0, 0)], Vector2i(1, 1)))
	assert_true(board.can_place([Vector2i(0, 0)], Vector2i(2, 1)))


func test_get_full_rows_detects_a_complete_row() -> void:
	for x in 4:
		board.lock_cells([Vector2i(0, 0)], Vector2i(x, 2), 1)
	assert_eq(board.get_full_rows(), [2])


func test_clear_full_rows_shifts_everything_down() -> void:
	# Row 3 (bottom) full, row 2 has one block that should fall to row 3.
	for x in 4:
		board.lock_cells([Vector2i(0, 0)], Vector2i(x, 3), 1)
	board.lock_cells([Vector2i(0, 0)], Vector2i(1, 2), 2)

	var cleared := board.clear_full_rows()

	assert_eq(cleared, [3])
	assert_eq(board.get_cell(1, 3), 2, "block above the cleared row falls down")
	assert_eq(board.get_cell(1, 2), BoardModel.EMPTY, "vacated row is empty")
	assert_eq(board.get_full_rows(), [], "no rows remain full")


func test_clear_multiple_rows_at_once() -> void:
	for y in [2, 3]:
		for x in 4:
			board.lock_cells([Vector2i(0, 0)], Vector2i(x, y), 1)
	var cleared := board.clear_full_rows()
	assert_eq(cleared, [2, 3])
	for y in 4:
		for x in 4:
			assert_eq(board.get_cell(x, y), BoardModel.EMPTY)


func test_reset_clears_the_board() -> void:
	board.lock_cells([Vector2i(0, 0)], Vector2i(0, 0), 1)
	board.reset()
	assert_eq(board.get_cell(0, 0), BoardModel.EMPTY)
