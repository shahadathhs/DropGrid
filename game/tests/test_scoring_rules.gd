extends GutTest
## Scoring and difficulty rules from docs/README_GAMEPLAY_FEATURES.md section 4:
## points per clear, a new level every 10 lines, and a fall speed that eases up to a floor.


func test_points_table_is_100_300_500_800_times_the_level() -> void:
	assert_eq(GameController.points_for_lines(1, 1), 100)
	assert_eq(GameController.points_for_lines(2, 1), 300)
	assert_eq(GameController.points_for_lines(3, 1), 500)
	assert_eq(GameController.points_for_lines(4, 1), 800)
	assert_eq(GameController.points_for_lines(1, 3), 300)
	assert_eq(GameController.points_for_lines(2, 3), 900)
	assert_eq(GameController.points_for_lines(3, 3), 1500)
	assert_eq(GameController.points_for_lines(4, 3), 2400)


func test_zero_lines_scores_nothing() -> void:
	assert_eq(GameController.points_for_lines(0, 5), 0)


func test_level_is_one_for_the_first_ten_lines() -> void:
	assert_eq(GameController.level_for_lines(0), 1)
	assert_eq(GameController.level_for_lines(9), 1)


func test_level_goes_up_every_ten_lines() -> void:
	assert_eq(GameController.level_for_lines(10), 2)
	assert_eq(GameController.level_for_lines(19), 2)
	assert_eq(GameController.level_for_lines(20), 3)
	assert_eq(GameController.level_for_lines(105), 11)


func test_first_level_fall_interval_is_the_base_interval() -> void:
	assert_almost_eq(GameController.fall_interval(1), GameConfig.BASE_FALL_INTERVAL, 0.0001)


func test_fall_interval_shrinks_each_level() -> void:
	var previous := GameController.fall_interval(1)
	for level in range(2, 10):
		var interval := GameController.fall_interval(level)
		assert_lt(
			interval, previous, "level %d should fall faster than level %d" % [level, level - 1]
		)
		previous = interval


func test_fall_interval_never_drops_below_the_floor() -> void:
	for level in [20, 50, 500]:
		assert_almost_eq(
			GameController.fall_interval(level),
			GameConfig.MIN_FALL_INTERVAL,
			0.0001,
			"level %d should be at the minimum fall interval" % level
		)


func test_hud_drop_value_for_level_one_reads_0_80s() -> void:
	assert_eq("%.2fs" % GameController.fall_interval(1), "0.80s")
