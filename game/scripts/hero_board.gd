extends Control
## The menu hero: a small still life of settled pieces, drawn with the same
## block style and palette as the board. Pure decoration, drawn once.

const ARRANGEMENT := [
	# [type, column, row] on a 8 x 4 mini board. Types are PieceData 0..6.
	[6, 0, 3],
	[6, 1, 3],
	[1, 3, 3],
	[1, 4, 3],
	[5, 5, 3],
	[2, 6, 2],
	[2, 5, 3],
	[2, 6, 3],
	[4, 1, 2],
	[5, 4, 2],
	[3, 0, 1],
	[6, 1, 2],
	[6, 2, 2],
	[1, 3, 2],
	[5, 5, 2],
	[4, 5, 1],
	[5, 4, 1],
	[2, 6, 1],
	[3, 6, 0],
	[4, 4, 0],
]

const COLS := 8
const ROWS := 4
const CELL := 34.0


func _ready() -> void:
	custom_minimum_size = Vector2(COLS * CELL, ROWS * CELL)


func _draw() -> void:
	for entry in ARRANGEMENT:
		var type: int = entry[0]
		var column: int = entry[1]
		var row: int = entry[2]
		var fill: Color = Palette.PIECE_COLORS[type + 1]
		CellStyle.draw_block(self, CellStyle.tile_rect(Vector2.ZERO, CELL, column, row), CELL, fill)
