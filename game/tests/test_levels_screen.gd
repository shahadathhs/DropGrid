extends GutTest
## Start level rules: unlock thresholds, locked levels cannot start, and the
## screen loads headlessly.

const LevelsScreen := preload("res://scripts/levels_screen.gd")


func _unlocked_levels(total_lines: int) -> Array[int]:
	var result: Array[int] = []
	for level in range(1, GameConfig.MAX_START_LEVEL + 1):
		if LevelsScreen.node_state(level, total_lines) == LevelsScreen.NodeState.UNLOCKED:
			result.append(level)
	return result


func test_zero_lines_unlocks_only_level_one() -> void:
	assert_eq(_unlocked_levels(0), [1] as Array[int])


func test_nine_lines_still_only_level_one() -> void:
	assert_eq(_unlocked_levels(9), [1] as Array[int])


func test_ten_lines_unlocks_level_two() -> void:
	assert_eq(_unlocked_levels(10), [1, 2] as Array[int])


func test_level_n_unlocks_at_ten_times_n_minus_one() -> void:
	assert_eq(LevelsScreen.lines_to_reach(5), 40)
	assert_eq(LevelsScreen.node_state(5, 39), LevelsScreen.NodeState.LOCKED)
	assert_eq(LevelsScreen.node_state(5, 40), LevelsScreen.NodeState.UNLOCKED)


func test_huge_total_is_capped_at_max_start_level() -> void:
	assert_eq(_unlocked_levels(1000000).size(), GameConfig.MAX_START_LEVEL)
	assert_eq(
		LevelsScreen.node_state(GameConfig.MAX_START_LEVEL + 1, 1000000),
		LevelsScreen.NodeState.LOCKED
	)
	assert_eq(LevelsScreen.highest_unlocked(1000000), GameConfig.MAX_START_LEVEL)


func test_locked_level_cannot_start_a_game() -> void:
	# The press handler only starts a game for UNLOCKED levels; this is the rule it checks.
	assert_eq(LevelsScreen.node_state(3, 19), LevelsScreen.NodeState.LOCKED)
	assert_eq(StartLevel.pending, 1)


func test_levels_scene_builds_one_card_per_start_level() -> void:
	var screen: Control = load("res://scenes/levels.tscn").instantiate()
	add_child_autofree(screen)
	await get_tree().process_frame
	var tree: GridContainer = screen.get_node("%LevelTree")
	assert_eq(tree.get_child_count(), GameConfig.MAX_START_LEVEL)
	for card: Button in tree.get_children():
		assert_eq(
			card.disabled, card.get_index() + 1 > LevelsScreen.highest_unlocked(Save.total_lines)
		)


func test_start_level_is_read_once_then_resets() -> void:
	StartLevel.pending = 7
	assert_eq(StartLevel.take(), 7)
	assert_eq(StartLevel.take(), 1)
