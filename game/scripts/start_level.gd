class_name StartLevel
extends RefCounted
## Hands the chosen start level from the levels screen to the game scene.
## The game reads it once with take(); after that it is back to level 1, so the
## main menu's Play always starts at level 1.

static var pending := 1


static func take() -> int:
	var level := pending
	pending = 1
	return level
