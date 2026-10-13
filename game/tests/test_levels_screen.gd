extends GutTest
## Level path rules: node states come from total lines, and the screen loads headlessly.

const LevelsScreen := preload("res://scripts/levels_screen.gd")


func test_level_one_is_current_before_any_lines() -> void:
	assert_eq(LevelsScreen.node_state(1, 0), LevelsScreen.NodeState.CURRENT)


func test_node_is_completed_once_the_next_level_is_reached() -> void:
	# Node 1 is completed at 10 lines (level 2 reached); node 2 is still ahead.
	assert_eq(LevelsScreen.node_state(1, 10), LevelsScreen.NodeState.COMPLETED)
	assert_eq(LevelsScreen.node_state(2, 10), LevelsScreen.NodeState.CURRENT)


func test_nodes_after_the_current_level_are_locked() -> void:
	assert_eq(LevelsScreen.node_state(3, 10), LevelsScreen.NodeState.LOCKED)
	assert_eq(LevelsScreen.node_state(12, 10), LevelsScreen.NodeState.LOCKED)


func test_node_n_completes_at_ten_times_n_lines() -> void:
	assert_eq(LevelsScreen.node_state(2, 19), LevelsScreen.NodeState.CURRENT)
	assert_eq(LevelsScreen.node_state(2, 20), LevelsScreen.NodeState.COMPLETED)
	assert_eq(LevelsScreen.node_state(3, 20), LevelsScreen.NodeState.CURRENT)


func test_locked_node_names_the_lines_needed() -> void:
	# Locked node n needs level n, which is reached at 10 * (n - 1) lines.
	assert_eq(LevelsScreen.lines_to_reach(2), 10)
	assert_eq(LevelsScreen.lines_to_reach(5), 40)
	assert_eq(LevelsScreen.node_state(5, 39), LevelsScreen.NodeState.LOCKED)


func test_levels_scene_loads_and_builds_twelve_nodes() -> void:
	var screen: Control = load("res://scenes/levels.tscn").instantiate()
	add_child_autofree(screen)
	await get_tree().process_frame
	var tree: VBoxContainer = screen.get_node("%LevelTree")
	assert_eq(tree.get_child_count(), LevelsScreen.NODE_COUNT)
