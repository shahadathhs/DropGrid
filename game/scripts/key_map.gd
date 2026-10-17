class_name KeyMap
extends RefCounted
## Keyboard layout: which key triggers which game action. Pure, so tests can
## cover the table without a scene. The site's controls table mirrors this.

const LEFT := &"left"
const RIGHT := &"right"
const SOFT_DROP := &"soft_drop"
const ROTATE := &"rotate"
const HOLD := &"hold"
const HARD_DROP := &"hard_drop"
const PAUSE := &"pause"


## The action for a keycode, or an empty name when the key is not mapped.
static func action_for(keycode: int) -> StringName:
	match keycode:
		KEY_LEFT, KEY_A:
			return LEFT
		KEY_RIGHT, KEY_D:
			return RIGHT
		KEY_DOWN, KEY_S:
			return SOFT_DROP
		KEY_UP, KEY_X:
			return ROTATE
		KEY_C, KEY_SHIFT:
			return HOLD
		KEY_SPACE:
			return HARD_DROP
		KEY_P, KEY_ESCAPE:
			return PAUSE
	return &""
