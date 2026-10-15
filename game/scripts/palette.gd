class_name Palette
extends RefCounted
## Color tokens from the approved design (the original globals.css mockup).
## The shared Theme (scripts/game_theme.gd) reads these, so change a color here only.

const BACKGROUND := Color("0B1020")
const BACKGROUND_DEEP := Color("070B14")
const SURFACE := Color("111A2C")
const SURFACE_2 := Color("17223A")
const SURFACE_3 := Color("1E2B46")
const LINE := Color("1D2840")
const LINE_STRONG := Color("293653")
const TEXT := Color("EDF1FA")
const TEXT_MUTED := Color("93A1BA")
const TEXT_FAINT := Color("5C6C88")
const ACCENT := Color("7C9CFF")
const ACCENT_SOFT := Color("26355C")
const ACCENT_INK := Color("0A0F1E")
const ACCENT_BORDER := Color("33457A") # level pill and guest banner border
const ACCENT_ROW_BORDER := Color("4A64A8") # highlighted "you" row border
## Mint, used for success and progress.
const SUCCESS := Color("62E6B5")
const WARNING := Color("FFC96B")
const DANGER := Color("FF7D92")
const DANGER_SOFT := Color("2A1620") # danger button and error box fill
const DANGER_LINE := Color("5A2A38") # danger button and error box border
const PANEL := Color(0.07, 0.11, 0.19, 0.95) # pause panel, slightly see-through

## Board colors. The board is drawn with BOARD_BG, empty cells with BOARD_CELL, and grid lines with GRID.
const BOARD_BG := Color("0A0F1A")
const BOARD_CELL := Color("0E1626")
const GRID := Color("1D2840")

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
