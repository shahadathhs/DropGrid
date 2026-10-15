extends Control
## Draws the next piece centered in this control, using the real queued piece
## from the game. Same block style as the board (flat fill inside a darker frame).
## Pure view: the piece type is set by hud_controller.gd.

const GAP := 2.0

var _type := -1


## Shows a piece type (PieceData.Type), or nothing when the type is negative.
func show_type(type: int) -> void:
	_type = type
	queue_redraw()


func _draw() -> void:
	if _type < 0 or size.x <= 0.0 or size.y <= 0.0:
		return
	var cells := PieceData.cells(_type, 0)
	var min_cell := Vector2i(99, 99)
	var max_cell := Vector2i(-1, -1)
	for cell in cells:
		min_cell = Vector2i(mini(min_cell.x, cell.x), mini(min_cell.y, cell.y))
		max_cell = Vector2i(maxi(max_cell.x, cell.x), maxi(max_cell.y, cell.y))
	var span := max_cell - min_cell + Vector2i.ONE
	# Fit the piece's bounding box into this control.
	var side := minf(
		(size.x - (span.x - 1) * GAP) / span.x,
		(size.y - (span.y - 1) * GAP) / span.y)
	side = floorf(side)
	var used := Vector2(span) * side + Vector2(span - Vector2i.ONE) * GAP
	var origin := ((size - used) * 0.5).floor()
	var fill: Color = Palette.PIECE_COLORS[PieceData.color_index(_type)]
	for cell in cells:
		var pos := origin + Vector2(cell - min_cell) * (side + GAP)
		var rect := Rect2(pos, Vector2(side, side))
		CellStyle.draw_block(self, rect, side, fill)
