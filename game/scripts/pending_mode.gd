class_name PendingMode
extends RefCounted
## Hands the chosen mode from the mode picker to the game scene, the same way
## StartLevel hands over the start level. take() resets it to marathon, so the
## menu's Play always starts a fresh marathon unless a picker says otherwise.

static var pending := GameMode.new()


static func take() -> GameMode:
	var mode := pending
	pending = GameMode.new()
	return mode
