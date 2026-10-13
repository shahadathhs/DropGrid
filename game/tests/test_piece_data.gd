extends GutTest


func test_rotation_wraps_every_four_turns() -> void:
	var r0 := PieceData.cells(PieceData.Type.T, 0)
	var r4 := PieceData.cells(PieceData.Type.T, 4)
	assert_eq(r0, r4)


func test_o_piece_is_rotation_invariant() -> void:
	var r0 := PieceData.cells(PieceData.Type.O, 0)
	var r1 := PieceData.cells(PieceData.Type.O, 1)
	assert_eq(r0, r1)


func test_i_piece_has_four_cells_at_every_rotation() -> void:
	for rotation in 4:
		assert_eq(PieceData.cells(PieceData.Type.I, rotation).size(), 4)


func test_color_index_is_one_based() -> void:
	assert_eq(PieceData.color_index(PieceData.Type.I), 1)
	assert_eq(PieceData.color_index(PieceData.Type.L), 7)
