extends Control
## Renders the logical board: grid, locked cells, ghost preview, active piece.
## Pure view: reads GameController state, decides nothing about the rules.

var game: GameController
var cols := GameConfig.COLS
var rows := GameConfig.ROWS

const LOCK_FLASH_TIME := 0.12
var _flash_cells: Array[Vector2i] = []
var _flash_timer := 0.0
## Cached StyleBoxFlat per (color, corner radius), for the rounded mockup look.
var _cell_styles: Dictionary = {}
## The full-width board panel behind the grid (built once).
var _panel: StyleBoxFlat


func setup(controller: GameController) -> void:
	game = controller
	cols = game.board.cols
	rows = game.board.rows
	game.board_changed.connect(queue_redraw)
	game.piece_locked.connect(_on_piece_locked)
	resized.connect(queue_redraw) # containers set our size after setup
	queue_redraw()


func _on_piece_locked(cells: Array[Vector2i]) -> void:
	_flash_cells = cells
	_flash_timer = LOCK_FLASH_TIME


func _process(delta: float) -> void:
	if _flash_timer > 0.0:
		_flash_timer = maxf(0.0, _flash_timer - delta)
		queue_redraw()


func _cell_size() -> float:
	return minf(size.x / cols, size.y / rows)


## Design units -> device pixels. The stretch scale times the display scale
## (2.0 on a Retina screen). Used to keep hairlines crisp: a 1.0-unit line
## would be half a pixel on a phone, which renders as a blurry smear.
func _pixel_scale() -> float:
	return get_viewport().get_screen_transform().get_scale().x \
			* DisplayServer.screen_get_max_scale()


func _draw() -> void:
	if game == null:
		return
	var px := _pixel_scale()
	var cell := _cell_size()
	var board_px := Vector2(cell * cols, cell * rows)
	# Snap the board origin to the device pixel grid so cell edges stay sharp.
	var origin := ((size - board_px) * 0.5 * px).floor() / px

	# The panel spans the whole control, so the space beside the grid reads
	# as part of the board instead of dead background.
	draw_style_box(_panel_style(), Rect2(Vector2.ZERO, size))
	_draw_empty_cells(origin, cell)
	_draw_grid(origin, cell, px)
	_draw_locked_cells(origin, cell)
	if game.state == GameController.State.PLAYING and game.has_active:
		_draw_ghost(origin, cell)
		_draw_active(origin, cell)


## Rounded, hairline-bordered board panel (the mockup's board card).
func _panel_style() -> StyleBoxFlat:
	if _panel == null:
		_panel = StyleBoxFlat.new()
		_panel.bg_color = Palette.BOARD_BG
		_panel.border_color = Palette.LINE
		_panel.set_border_width_all(2)
		_panel.set_corner_radius_all(16)
	return _panel


## Empty cells get a slightly lighter square with a small gap, like the prototype's board cells.
func _draw_empty_cells(origin: Vector2, cell: float) -> void:
	var inset := cell * 0.06
	for y in rows:
		for x in cols:
			var pos := origin + Vector2(x, y) * cell
			draw_rect(Rect2(pos + Vector2(inset, inset), Vector2(cell - inset * 2, cell - inset * 2)), Palette.BOARD_CELL)


## Grid lines snap to device pixels and are exactly one device pixel wide.
func _draw_grid(origin: Vector2, cell: float, px: float) -> void:
	var line_width := 1.0 / px
	for x in range(1, cols):
		var gx := roundf((origin.x + x * cell) * px) / px
		draw_line(Vector2(gx, origin.y), Vector2(gx, origin.y + rows * cell), Palette.GRID, line_width)
	for y in range(1, rows):
		var gy := roundf((origin.y + y * cell) * px) / px
		draw_line(Vector2(origin.x, gy), Vector2(origin.x + cols * cell, gy), Palette.GRID, line_width)


func _draw_locked_cells(origin: Vector2, cell: float) -> void:
	for y in rows:
		for x in cols:
			var value := game.board.get_cell(x, y)
			if value == BoardModel.EMPTY:
				continue
			_draw_cell(origin, cell, x, y, Palette.PIECE_COLORS[value])
			# The lock flash is an overlay, so the cached style is reused.
			if _flash_timer > 0.0 and _flash_cells.has(Vector2i(x, y)):
				var pos := origin + Vector2(x, y) * cell
				var inset := cell * 0.06
				var flash_rect := Rect2(pos + Vector2(inset, inset),
						Vector2(cell - inset * 2, cell - inset * 2))
				draw_rect(flash_rect, Color(1, 1, 1, _flash_timer / LOCK_FLASH_TIME * 0.6))


func _draw_ghost(origin: Vector2, cell: float) -> void:
	var color := Palette.PIECE_COLORS[PieceData.color_index(game.active_type)]
	color.a = 0.22
	for pos in game.ghost_cells():
		_draw_cell(origin, cell, pos.x, pos.y, color, false)


func _draw_active(origin: Vector2, cell: float) -> void:
	var color: Color = Palette.PIECE_COLORS[PieceData.color_index(game.active_type)]
	for pos in game.active_cells():
		_draw_cell(origin, cell, pos.x, pos.y, color)


func _draw_cell(origin: Vector2, cell: float, x: int, y: int, color: Color, with_inset := true) -> void:
	var pos := origin + Vector2(x, y) * cell
	var inset := cell * 0.06 if with_inset else 0.0
	var rect := Rect2(pos + Vector2(inset, inset), Vector2(cell - inset * 2, cell - inset * 2))
	draw_style_box(_piece_style(color, cell), rect)


## Rounded block style, cached per color and radius so redraws stay cheap.
## A subtle lighter border gives the block its top-lit mockup look.
func _piece_style(color: Color, cell: float) -> StyleBoxFlat:
	var radius := int(cell * 0.16)
	var key := "%s_%d" % [color.to_html(), radius]
	if not _cell_styles.has(key):
		var box := StyleBoxFlat.new()
		box.bg_color = color
		box.set_corner_radius_all(radius)
		box.border_color = color.lightened(0.3)
		box.set_border_width_all(2)
		_cell_styles[key] = box
	return _cell_styles[key]
