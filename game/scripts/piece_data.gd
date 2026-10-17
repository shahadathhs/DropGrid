class_name PieceData
extends RefCounted
## Piece shapes as cell offsets inside a small local box. X grows right, Y grows down.

enum Type { I, O, T, S, Z, J, L }

const TYPE_COUNT := 7

# Cells of rotation 0. Further rotations are derived by turning clockwise.
const BASE_CELLS := {
	Type.I: [Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1)],
	Type.O: [Vector2i(1, 0), Vector2i(2, 0), Vector2i(1, 1), Vector2i(2, 1)],
	Type.T: [Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)],
	Type.S: [Vector2i(1, 0), Vector2i(2, 0), Vector2i(0, 1), Vector2i(1, 1)],
	Type.Z: [Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1), Vector2i(2, 1)],
	Type.J: [Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)],
	Type.L: [Vector2i(2, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)],
}

# Side length of the square box each shape rotates inside.
const BOX_SIZE := {
	Type.I: 4,
	Type.O: 4,
	Type.T: 3,
	Type.S: 3,
	Type.Z: 3,
	Type.J: 3,
	Type.L: 3,
}


## Local cells of a piece for a rotation index (any integer; wraps every 4).
static func cells(type: int, rotation: int) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	var box: int = BOX_SIZE[type]
	var turns := posmod(rotation, 4)
	for base in BASE_CELLS[type]:
		var cell: Vector2i = base
		if type != Type.O:
			for i in turns:
				# One clockwise turn inside the box.
				cell = Vector2i(box - 1 - cell.y, cell.x)
		result.append(cell)
	return result


## Value stored in the board (and used to look up Palette.PIECE_COLORS) for a piece.
static func color_index(type: int) -> int:
	return type + 1
