extends Control
## Renders the logical board: grid, locked cells, ghost preview, active piece.
## Pure view: reads GameController state, decides nothing about the rules.

var game: GameController
var cols := GameConfig.COLS
var rows := GameConfig.ROWS

const LOCK_FLASH_TIME := 0.12
var _flash_cells: Array[Vector2i] = []
var _flash_timer := 0.0


func setup(controller: GameController) -> void:
	game = controller
	cols = game.board.cols
	rows = game.board.rows
	game.board_changed.connect(queue_redraw)
	game.piece_locked.connect(_on_piece_locked)
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


func _draw() -> void:
	if game == null:
		return
	var cell := _cell_size()
	var board_px := Vector2(cell * cols, cell * rows)
	var origin := (size - board_px) * 0.5

	draw_rect(Rect2(origin, board_px), Palette.BOARD_BG)
	_draw_grid(origin, cell)
	_draw_locked_cells(origin, cell)
	if game.state == GameController.State.PLAYING and game.has_active:
		_draw_ghost(origin, cell)
		_draw_active(origin, cell)
	draw_rect(Rect2(origin, board_px), Palette.GRID, false, 2.0)


func _draw_grid(origin: Vector2, cell: float) -> void:
	for x in range(1, cols):
		var px := origin.x + x * cell
		draw_line(Vector2(px, origin.y), Vector2(px, origin.y + rows * cell), Palette.GRID, 1.0)
	for y in range(1, rows):
		var py := origin.y + y * cell
		draw_line(Vector2(origin.x, py), Vector2(origin.x + cols * cell, py), Palette.GRID, 1.0)


func _draw_locked_cells(origin: Vector2, cell: float) -> void:
	for y in rows:
		for x in cols:
			var value := game.board.get_cell(x, y)
			if value == BoardModel.EMPTY:
				continue
			var color: Color = Palette.PIECE_COLORS[value]
			if _flash_timer > 0.0 and _flash_cells.has(Vector2i(x, y)):
				color = color.lightened(_flash_timer / LOCK_FLASH_TIME * 0.6)
			_draw_cell(origin, cell, x, y, color)


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
	draw_rect(Rect2(pos + Vector2(inset, inset), Vector2(cell - inset * 2, cell - inset * 2)), color)
