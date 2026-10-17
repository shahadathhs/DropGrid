class_name BrandMark
extends Control
## Draws the DropGrid mark from the prototype: four small squares tilted -8 degrees.
## GRID is the small 2x2 mark next to the wordmark. DIAGONAL is the
## three-square mark on the game over screen.

enum Style { GRID, DIAGONAL }

const TILT_DEGREES := -8.0

@export var style := Style.GRID


func _ready() -> void:
	resized.connect(_update_pivot)
	_update_pivot()
	rotation = deg_to_rad(TILT_DEGREES)


func _update_pivot() -> void:
	# Rotate around the middle of the control, not its top-left corner.
	pivot_offset = size * 0.5


func _draw() -> void:
	if style == Style.GRID:
		# Top-left accent, then cyan, purple, and pink (prototype order).
		var square := size.x * 0.43
		var gap := size.x * 0.14
		_square(Vector2(0, 0), square, Palette.ACCENT)
		_square(Vector2(square + gap, 0), square, Palette.PIECE_COLORS[1])
		_square(Vector2(0, square + gap), square, Palette.PIECE_COLORS[3])
		_square(Vector2(square + gap, square + gap), square, Palette.PIECE_COLORS[5])
	else:
		# Three squares running down and to the right, cyan, purple, and pink.
		# Positions are the prototype's (8, 18, 28 px in a 44 px box), as fractions of the size.
		var square := size.x * 0.2
		var first := size.x * 0.18
		var step := size.x * 0.23
		_square(Vector2(first, first), square, Palette.PIECE_COLORS[1])
		_square(Vector2(first + step, first + step), square, Palette.PIECE_COLORS[3])
		_square(Vector2(first + step * 2.0, first + step * 2.0), square, Palette.PIECE_COLORS[5])


func _square(top_left: Vector2, side: float, color: Color) -> void:
	draw_rect(Rect2(top_left, Vector2(side, side)), color)
