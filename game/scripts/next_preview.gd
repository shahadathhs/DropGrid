extends Control
## Draws the next piece in the game header, using the real queued piece from the game.
## Pure view: the piece type is set by hud_controller.gd, never decided here.

const CELL_GAP := 2.0

var _type := -1


## Shows a piece type (PieceData.Type), or nothing when the type is negative.
func show_type(type: int) -> void:
	_type = type
	queue_redraw()


func _draw() -> void:
	if _type < 0:
		return
	var cells := PieceData.cells(_type, 0)
	# Find the top-left corner of the piece so it is drawn from the top-left of this control.
	var min_x := 99
	var min_y := 99
	for cell in cells:
		min_x = mini(min_x, cell.x)
		min_y = mini(min_y, cell.y)
	var side := minf(size.x / 4.0, size.y / 2.0)
	var color: Color = Palette.PIECE_COLORS[PieceData.color_index(_type)]
	for cell in cells:
		var pos := Vector2(cell.x - min_x, cell.y - min_y) * (side + CELL_GAP)
		draw_rect(Rect2(pos, Vector2(side, side)), color)
