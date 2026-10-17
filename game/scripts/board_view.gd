extends Control
## Renders the logical board: empty tiles, locked cells, ghost preview, active piece.
## Pure view: reads GameController state, decides nothing about the rules.
##
## Everything is drawn from one unit, the cell (see CellStyle). The active piece has an
## ink frame, the ghost is a frame with no fill. No gradients, highlights, glow, or grid lines.

const LOCK_FLASH_TIME := 0.12

var game: GameController
var cols := GameConfig.COLS
var rows := GameConfig.ROWS

var _flash_cells: Array[Vector2i] = []
var _flash_timer := 0.0


func setup(controller: GameController) -> void:
	game = controller
	cols = game.board.cols
	rows = game.board.rows
	game.board_changed.connect(queue_redraw)
	game.piece_locked.connect(_on_piece_locked)
	resized.connect(queue_redraw)  # containers set our size after setup
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


## Design units -> device pixels: the stretch scale times the display scale.
func _pixel_scale() -> float:
	return (
		get_viewport().get_screen_transform().get_scale().x * DisplayServer.screen_get_max_scale()
	)


func _draw() -> void:
	if game == null:
		return
	var cell := _cell_size()
	var board_px := Vector2(cell * cols, cell * rows)
	# Snap the board origin to the device pixel grid so tile edges stay sharp.
	var px := _pixel_scale()
	var origin := ((size - board_px) * 0.5 * px).floor() / px

	_draw_empty_cells(origin, cell)
	_draw_locked_cells(origin, cell)
	if game.state == GameController.State.PLAYING and game.has_active:
		_draw_ghost(origin, cell)
		_draw_active(origin, cell)


func _draw_empty_cells(origin: Vector2, cell: float) -> void:
	for y in rows:
		for x in cols:
			draw_rect(CellStyle.tile_rect(origin, cell, x, y), Palette.BOARD_CELL)


func _draw_locked_cells(origin: Vector2, cell: float) -> void:
	for y in rows:
		for x in cols:
			var value := game.board.get_cell(x, y)
			if value == BoardModel.EMPTY:
				continue
			var color: Color = Palette.PIECE_COLORS[value]
			var rect := CellStyle.tile_rect(origin, cell, x, y)
			CellStyle.draw_block(self, rect, cell, color)
			# The lock flash is an ink frame that fades out over a few frames.
			if _flash_timer > 0.0 and _flash_cells.has(Vector2i(x, y)):
				CellStyle.draw_frame(
					self, rect, cell, Color(Palette.ACCENT, _flash_timer / LOCK_FLASH_TIME)
				)


func _draw_ghost(origin: Vector2, cell: float) -> void:
	var color: Color = Palette.PIECE_COLORS[PieceData.color_index(game.active_type)]
	for pos in game.ghost_cells():
		CellStyle.draw_frame(self, CellStyle.tile_rect(origin, cell, pos.x, pos.y), cell, color)


func _draw_active(origin: Vector2, cell: float) -> void:
	var color: Color = Palette.PIECE_COLORS[PieceData.color_index(game.active_type)]
	for pos in game.active_cells():
		CellStyle.draw_block(
			self, CellStyle.tile_rect(origin, cell, pos.x, pos.y), cell, color, Palette.ACCENT
		)
