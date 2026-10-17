class_name Wordmark
extends Control
## The DropGrid wordmark, drawn from the same blocks as the board. Each letter is a
## 3 x 5 pattern of cells in one piece color. Two rows ("DROP" over "GRID") fill a
## square-ish area; one row ("DROPGRID") fits a narrow strip.

const LETTER_WIDTH := 3
const LETTER_HEIGHT := 5
const LETTER_GAP := 1

const GLYPHS := {
	"D": ["110", "101", "101", "101", "110"],
	"R": ["110", "101", "110", "101", "101"],
	"O": ["111", "101", "101", "101", "111"],
	"P": ["110", "101", "110", "100", "100"],
	"G": ["011", "100", "101", "101", "011"],
	"I": ["111", "010", "010", "010", "111"],
}

@export var two_rows := true


func _draw() -> void:
	var rows: Array[String] = []
	if two_rows:
		rows.assign(["DROP", "GRID"])
	else:
		rows.assign(["DROPGRID"])
	var letters_wide := rows[0].length()
	var cells_wide := letters_wide * LETTER_WIDTH + (letters_wide - 1) * LETTER_GAP
	var cells_high := rows.size() * LETTER_HEIGHT + (rows.size() - 1) * LETTER_GAP
	var cell := floorf(minf(size.x / cells_wide, size.y / cells_high))
	if cell < 1.0:
		return
	var origin := ((size - Vector2(cells_wide, cells_high) * cell) * 0.5).floor()
	var color_index := 0
	for row in rows.size():
		for letter in rows[row].length():
			color_index = color_index % 7 + 1
			var fill: Color = Palette.PIECE_COLORS[color_index]
			var glyph: Array = GLYPHS[rows[row][letter]]
			var left := letter * (LETTER_WIDTH + LETTER_GAP)
			var top := row * (LETTER_HEIGHT + LETTER_GAP)
			for y in LETTER_HEIGHT:
				for x in LETTER_WIDTH:
					if glyph[y][x] == "1":
						CellStyle.draw_block(
							self, CellStyle.tile_rect(origin, cell, left + x, top + y), cell, fill
						)
