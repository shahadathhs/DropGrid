class_name ToggleSwitch
extends Control
## Square on/off switch drawn in the cell language: a track two cells wide and one tall,
## with a square knob. On is filled ink with an ink-colored knob; off is outlined with a
## muted knob at the other end. The state changes instantly.

const CELL := 40.0
const BORDER := 2.0
const KNOB_INSET := 6.0

var on := false:
	set(value):
		on = value
		queue_redraw()


func _init() -> void:
	custom_minimum_size = Vector2(CELL * 2.0, CELL)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _draw() -> void:
	var track := Rect2(Vector2.ZERO, Vector2(CELL * 2.0, CELL))
	var knob_size := CELL - KNOB_INSET * 2.0
	var knob_y := KNOB_INSET
	if on:
		draw_rect(track, Palette.ACCENT)
		draw_rect(Rect2(CELL * 2.0 - KNOB_INSET - knob_size, knob_y, knob_size, knob_size), Palette.ACCENT_INK)
	else:
		draw_rect(track, Palette.LINE_STRONG, false, BORDER)
		draw_rect(Rect2(KNOB_INSET, knob_y, knob_size, knob_size), Palette.TEXT_MUTED)
