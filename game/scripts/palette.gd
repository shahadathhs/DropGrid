class_name Palette
extends RefCounted
## Color tokens, the only place colors are defined. GameTheme reads these.
## Two grounds share one design: warm graphite with off-white ink (dark) and
## off-white paper with graphite ink (light). The ink is also the accent: primary
## buttons are filled ink, so color is left to the pieces and one signal red.
## Pass `--light` after `--` on the command line to preview the light ground.

static var LIGHT := OS.get_cmdline_user_args().has("--light")

static var BACKGROUND := _pick("EFEBE2", "161513")
static var BACKGROUND_DEEP := _pick("E3DED2", "0F0E0D")
static var SURFACE := _pick("E6E1D6", "1F1D1A")
static var SURFACE_2 := _pick("DDD7CA", "2A2724")
static var SURFACE_3 := _pick("CFC8B9", "353230")
static var LINE := _pick("D5CFC1", "2B2824")
static var LINE_STRONG := _pick("9C9586", "4A453F")
static var TEXT := _pick("1B1A17", "ECE7DC")
static var TEXT_MUTED := _pick("6B665C", "A09A8E")
static var TEXT_FAINT := _pick("9A9488", "6E695F")
## Ink: fill of the primary button, selected states, and the active piece frame.
static var ACCENT := _pick("1B1A17", "ECE7DC")
static var ACCENT_SOFT := _pick("DDD7CA", "2A2724")
## Text and icons drawn on top of ACCENT.
static var ACCENT_INK := _pick("EFEBE2", "161513")
static var ACCENT_BORDER := _pick("9C9586", "4A453F")
static var ACCENT_ROW_BORDER := _pick("1B1A17", "ECE7DC")
static var SUCCESS := _pick("1B1A17", "ECE7DC")
## One signal color: hard drop, destructive actions, errors.
static var WARNING := _pick("D63A18", "FF5A36")
static var DANGER := _pick("D63A18", "FF5A36")
static var DANGER_SOFT := _pick("E8D3C9", "2E1A15")
static var DANGER_LINE := _pick("D63A18", "6B2E20")
static var PANEL := Color(BACKGROUND, 0.96)  # pause panel

## Board: the field is the ground itself; empty cells are slightly offset tiles.
static var BOARD_BG := _pick("EFEBE2", "161513")
static var BOARD_CELL := _pick("E3DED2", "262320")
## Unused now that the board draws tiles without grid lines; removed in a later pass.
static var GRID := Color(0, 0, 0, 0)

## Indexed by board cell value (0 = empty, 1..7 = piece color), see PieceData.
## Seven hues, and brightness spaced about 23 points apart (grayscale-safe):
## by brightness, dark ground: J T Z S L I O. Light ground is the same order, darker.
static var PIECE_COLORS: Array[Color] = [
	Color(0, 0, 0, 0),
	_pick("60CADA", "96DCE6"),  # I cyan
	_pick("EEC82F", "F6E292"),  # O yellow
	_pick("6F34B3", "874CCB"),  # T violet
	_pick("3FA66A", "58C083"),  # S green
	_pick("D43275", "DB548C"),  # Z magenta
	_pick("1C4283", "265AB4"),  # J blue
	_pick("F17E25", "F59F5D"),  # L orange
]


static func _pick(light_hex: String, dark_hex: String) -> Color:
	return Color(light_hex if LIGHT else dark_hex)
