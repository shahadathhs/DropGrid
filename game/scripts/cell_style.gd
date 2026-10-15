class_name CellStyle
extends RefCounted
## The one block look: a flat fill inside a darker frame, no gradient or highlight.
## The board, the next-piece preview, and the wordmark all draw through this.

## Gap between neighbouring tiles, and frame width, as fractions of the cell.
const GAP := 0.125
const FRAME := 0.125
## Frames are the fill pulled toward black, so each piece keeps its own hue.
const FRAME_DARKEN := 0.32


## A filled block: a frame-colored square with the flat fill inset by the frame width.
static func draw_block(canvas: CanvasItem, rect: Rect2, cell: float, fill: Color, frame := Color(0, 0, 0, 0)) -> void:
	var frame_color := frame if frame.a > 0.0 else fill.darkened(FRAME_DARKEN)
	canvas.draw_rect(rect, frame_color)
	canvas.draw_rect(rect.grow(-maxf(1.0, cell * FRAME)), fill)


## Only the frame, with nothing inside.
static func draw_frame(canvas: CanvasItem, rect: Rect2, cell: float, color: Color) -> void:
	var width := maxf(1.0, cell * FRAME)
	var inner_height := rect.size.y - width * 2.0
	canvas.draw_rect(Rect2(rect.position, Vector2(rect.size.x, width)), color)
	canvas.draw_rect(Rect2(rect.position + Vector2(0, rect.size.y - width), Vector2(rect.size.x, width)), color)
	canvas.draw_rect(Rect2(rect.position + Vector2(0, width), Vector2(width, inner_height)), color)
	canvas.draw_rect(Rect2(rect.position + Vector2(rect.size.x - width, width), Vector2(width, inner_height)), color)


## The tile for grid cell (x, y): the cell shrunk by half a gap on every side.
static func tile_rect(origin: Vector2, cell: float, x: int, y: int) -> Rect2:
	var gap := cell * GAP * 0.5
	return Rect2(origin + Vector2(x, y) * cell + Vector2(gap, gap), Vector2.ONE * (cell - gap * 2.0))
