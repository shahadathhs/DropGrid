class_name Palette
extends RefCounted
## Color tokens from docs/README_VISUAL_DESIGN.md.

const BACKGROUND := Color("0B1020")
const SURFACE := Color("121A2B")
const SURFACE_2 := Color("1B263B")
const BOARD_BG := Color("0A0F1A")
const GRID := Color("202B40")
const TEXT := Color("F3F6FC")
const TEXT_MUTED := Color("9AA8BE")
const ACCENT := Color("7C9CFF")
const SUCCESS := Color("62E6B5")
const WARNING := Color("FFC96B")
const DANGER := Color("FF7185")

# Indexed by board cell value (0 = empty, 1..7 = piece color), see PieceData.
const PIECE_COLORS: Array[Color] = [
	Color(0, 0, 0, 0),
	Color("55DDE0"), # I cyan
	Color("F6D365"), # O yellow
	Color("B38CFF"), # T purple
	Color("69D69B"), # S green
	Color("FF83B8"), # Z pink
	Color("6688FF"), # J blue
	Color("FFAA5C"), # L orange
]
