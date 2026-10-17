extends SceneTree
## Dumps a real, reachable board state from the actual game logic as JSON.
## Run: godot --headless --path game -s res://tools/dump_board.gd
## The seed is fixed and the naive greedy placer acts only through the public
## GameController API, so the output is a genuinely reachable state for
## site/src/lib/board-data.ts. Nothing here is invented.

const SEED := 2026
const PIECES := 26
const BOX_SIZE := [4, 4, 3, 3, 3, 3, 3]  # I, O, T, S, Z, J, L — see piece_data.gd
const BASE_CELLS := [
	[[0, 1], [1, 1], [2, 1], [3, 1]],  # I
	[[1, 0], [2, 0], [1, 1], [2, 1]],  # O
	[[1, 0], [0, 1], [1, 1], [2, 1]],  # T
	[[1, 0], [2, 0], [0, 1], [1, 1]],  # S
	[[0, 0], [1, 0], [1, 1], [2, 1]],  # Z
	[[0, 0], [0, 1], [1, 1], [2, 1]],  # J
	[[2, 0], [0, 1], [1, 1], [2, 1]],  # L
]


func _initialize() -> void:
	var controller := GameController.new(SEED, 1)
	for _piece in PIECES:
		if controller.state != GameController.State.PLAYING:
			break
		_play_one(controller)
	if controller.state != GameController.State.PLAYING:
		push_error("Seed %d ended in game over; pick another seed." % SEED)
		quit(1)
		return

	var rows: Array = []
	for y in controller.board.rows:
		var row: Array = []
		for x in controller.board.cols:
			row.append(controller.board.get_cell(x, y))
		rows.append(row)

	var cells_of := func(cells: Array[Vector2i]) -> Array:
		return cells.map(func(c: Vector2i) -> Array: return [c.x, c.y])

	var dump := {
		"cols": controller.board.cols,
		"rows": controller.board.rows,
		"board": rows,
		"active": {"type": controller.active_type, "cells": cells_of.call(controller.active_cells())},
		"ghost": cells_of.call(controller.ghost_cells()),
		"next": controller.next_type,
		"score": controller.score,
		"lines": controller.lines,
		"level": controller.level,
	}
	print(JSON.stringify(dump, "\t"))
	quit(0)


## Place the active piece greedily: maximize clears, then minimize holes,
## bumpiness, and height. Every action goes through the public API; the
## search simulates on a local copy of the grid.
func _play_one(controller: GameController) -> void:
	var cols: int = controller.board.cols
	var rows: int = controller.board.rows
	var grid: Array = []
	for y in rows:
		var row: Array = []
		for x in cols:
			row.append(controller.board.get_cell(x, y))
		grid.append(row)

	var best_rotation := 0
	var best_x := 0
	var best_score := -999999
	for rotation in 4:
		var cells := _cells_for(controller.active_type, rotation)
		var width := 0
		for c in cells:
			width = maxi(width, c[0] + 1)
		for x in cols - width + 1:
			var landing := _landing_y(controller, cells, x)
			if landing == -999:
				continue
			var trial: Array = []
			for row in grid:
				trial.append(row.duplicate())
			for c in cells:
				trial[landing + c[1]][x + c[0]] = 1
			trial = _clear_rows(trial)
			var score := _evaluate(trial, cols)
			if score > best_score:
				best_score = score
				best_rotation = rotation
				best_x = x

	while controller.active_rotation != best_rotation:
		controller.rotate_piece()
	var dx: int = best_x - controller.active_position.x
	while dx != 0:
		if not controller.move(1 if dx > 0 else -1):
			break
		dx = best_x - controller.active_position.x
	controller.hard_drop()


func _clear_rows(grid: Array) -> Array:
	var out: Array = []
	for row in grid:
		if row.has(0):
			out.append(row)
	while out.size() < grid.size():
		out.insert(0, [])
	return out


func _evaluate(grid: Array, cols: int) -> int:
	var heights: Array = []
	for x in cols:
		var h := 0
		for y in grid.size():
			if grid[y][x] > 0:
				h = grid.size() - y
				break
		heights.append(h)
	var holes := 0
	for x in cols:
		var seen := false
		for y in grid.size():
			if grid[y][x] > 0:
				seen = true
			elif seen:
				holes += 1
	var bumpiness := 0
	for x in cols - 1:
		bumpiness += absi(heights[x] - heights[x + 1])
	var aggregate := 0
	for h in heights:
		aggregate += h
	return -holes * 80 - bumpiness * 20 - aggregate * 4


func _cells_for(type: int, rotation: int) -> Array:
	var box: int = BOX_SIZE[type]
	var cells: Array = []
	for cell in BASE_CELLS[type]:
		var x: int = cell[0]
		var y: int = cell[1]
		for _turn in posmod(rotation, 4):
			var nx := box - 1 - y
			y = x
			x = nx
		cells.append([x, y])
	return cells


func _landing_y(controller: GameController, cells: Array, x: int) -> int:
	var to_vectors := func(pair_cells: Array, y: int) -> Array[Vector2i]:
		var out: Array[Vector2i] = []
		for c in pair_cells:
			out.append(Vector2i(x + c[0], y + c[1]))
		return out
	for y in range(-2, controller.board.rows):
		var here: Array[Vector2i] = to_vectors.call(cells, y)
		if not controller.board.can_place(here, Vector2i.ZERO):
			continue
		var below: Array[Vector2i] = to_vectors.call(cells, y + 1)
		if not controller.board.can_place(below, Vector2i.ZERO):
			return y
	return -999
