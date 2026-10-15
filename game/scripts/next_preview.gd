extends Control
## Draws the next piece centered in this control, using the real queued piece
## from the game. Pure view: the piece type is set by hud_controller.gd.

const CELL_GAP := 2.0
const MAX_SIDE := 26.0

var _type := -1


## Shows a piece type (PieceData.Type), or nothing when the type is negative.
func show_type(type: int) -> void:
	_type = type
	queue_redraw()


func _draw() -> void:
	if _type < 0 or size.x <= 0.0 or size.y <= 0.0:
		return
	var cells := PieceData.cells(_type, 0)
	# Bounding box of the piece's cells, so any type centers the same way.
	var min_x := 99
	var min_y := 99
	var max_x := -1
	var max_y := -1
	for cell in cells:
		min_x = mini(min_x, cell.x)
		min_y = mini(min_y, cell.y)
		max_x = maxi(max_x, cell.x)
		max_y = maxi(max_y, cell.y)
	var span := Vector2i(max_x - min_x + 1, max_y - min_y + 1)
	# Fit the bounding box, then cap so wide pieces stay in proportion.
	var side: float = minf(MAX_SIDE, minf(
		(size.x - (span.x - 1) * CELL_GAP) / span.x,
		(size.y - (span.y - 1) * CELL_GAP) / span.y))
	var used := Vector2(span.x * side + (span.x - 1) * CELL_GAP,
			span.y * side + (span.y - 1) * CELL_GAP)
	var origin := (size - used) * 0.5
	var box := StyleBoxFlat.new()
	box.bg_color = Palette.PIECE_COLORS[PieceData.color_index(_type)]
	box.set_corner_radius_all(int(side * 0.22))
	for cell in cells:
		var pos := origin + Vector2(cell.x - min_x, cell.y - min_y) * (side + CELL_GAP)
		draw_style_box(box, Rect2(pos, Vector2(side, side)))
