extends GutTest
## Keyboard table: every action has both of its keys; unmapped keys do nothing.


func test_move_keys() -> void:
	assert_eq(KeyMap.action_for(KEY_LEFT), KeyMap.LEFT)
	assert_eq(KeyMap.action_for(KEY_A), KeyMap.LEFT)
	assert_eq(KeyMap.action_for(KEY_RIGHT), KeyMap.RIGHT)
	assert_eq(KeyMap.action_for(KEY_D), KeyMap.RIGHT)


func test_soft_drop_keys() -> void:
	assert_eq(KeyMap.action_for(KEY_DOWN), KeyMap.SOFT_DROP)
	assert_eq(KeyMap.action_for(KEY_S), KeyMap.SOFT_DROP)


func test_rotate_keys() -> void:
	assert_eq(KeyMap.action_for(KEY_UP), KeyMap.ROTATE)
	assert_eq(KeyMap.action_for(KEY_X), KeyMap.ROTATE)


func test_hold_keys() -> void:
	assert_eq(KeyMap.action_for(KEY_C), KeyMap.HOLD)
	assert_eq(KeyMap.action_for(KEY_SHIFT), KeyMap.HOLD)


func test_hard_drop_key() -> void:
	assert_eq(KeyMap.action_for(KEY_SPACE), KeyMap.HARD_DROP)


func test_pause_keys() -> void:
	assert_eq(KeyMap.action_for(KEY_P), KeyMap.PAUSE)
	assert_eq(KeyMap.action_for(KEY_ESCAPE), KeyMap.PAUSE)


func test_unmapped_keys_have_no_action() -> void:
	assert_eq(KeyMap.action_for(KEY_Q), &"")
	assert_eq(KeyMap.action_for(KEY_F9), &"")
	assert_eq(KeyMap.action_for(KEY_NONE), &"")
