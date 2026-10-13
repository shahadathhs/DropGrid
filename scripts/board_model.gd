class_name BoardModel
extends RefCounted
## Logical grid. Knows nothing about pixels or nodes.
## Coordinates: x is the column (0 = left), y is the row (0 = top).
## A cell holds EMPTY (0) or a color index 1..7 (see PieceData.color_index).

const EMPTY := 0

var cols: int
var rows: int
var _cells := PackedInt32Array()


func _init(p_cols: int = GameConfig.COLS, p_rows: int = GameConfig.ROWS) -> void:
	cols = p_cols
	rows = p_rows
	reset()


func reset() -> void:
	_cells.resize(cols * rows)
	_cells.fill(EMPTY)


func is_inside(x: int, y: int) -> bool:
	return x >= 0 and x < cols and y >= 0 and y < rows


func get_cell(x: int, y: int) -> int:
	return _cells[y * cols + x]


func is_free(x: int, y: int) -> bool:
	return is_inside(x, y) and get_cell(x, y) == EMPTY


## True when every local cell, shifted by offset, is inside the board and empty.
func can_place(local_cells: Array[Vector2i], offset: Vector2i) -> bool:
	for cell in local_cells:
		var pos := cell + offset
		if not is_free(pos.x, pos.y):
			return false
	return true


func lock_cells(local_cells: Array[Vector2i], offset: Vector2i, color: int) -> void:
	for cell in local_cells:
		var pos := cell + offset
		if is_inside(pos.x, pos.y):
			_cells[pos.y * cols + pos.x] = color


func get_full_rows() -> Array[int]:
	var full: Array[int] = []
	for y in rows:
		var is_full := true
		for x in cols:
			if get_cell(x, y) == EMPTY:
				is_full = false
				break
		if is_full:
			full.append(y)
	return full


## Removes completed rows, drops everything above, and returns the cleared row
## indices as they were before the shift (ascending).
func clear_full_rows() -> Array[int]:
	var full := get_full_rows()
	if full.is_empty():
		return full
	var write_row := rows - 1
	for read_row in range(rows - 1, -1, -1):
		if full.has(read_row):
			continue
		if write_row != read_row:
			for x in cols:
				_cells[write_row * cols + x] = _cells[read_row * cols + x]
		write_row -= 1
	while write_row >= 0:
		for x in cols:
			_cells[write_row * cols + x] = EMPTY
		write_row -= 1
	return full
