extends GutTest


func test_each_bag_of_seven_contains_every_piece_once() -> void:
	var bag := PieceBag.new(42)
	var seen: Array[int] = []
	for i in PieceData.TYPE_COUNT:
		seen.append(bag.next_piece())
	seen.sort()
	var expected: Array[int] = []
	for t in PieceData.TYPE_COUNT:
		expected.append(t)
	assert_eq(seen, expected)


func test_bag_refills_after_seven() -> void:
	var bag := PieceBag.new(7)
	for i in 21:  # three full bags
		var piece := bag.next_piece()
		assert_true(piece >= 0 and piece < PieceData.TYPE_COUNT)
