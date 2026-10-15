extends Node
## Autoload singleton ("DevicePreview"): desktop-only mobile screen simulation.
## On PC, shrinks the window to a phone-shaped size so layouts can be checked
## without a device, and lets you switch sizes while the game is running.
## Inert on mobile/web exports (guarded by feature checks below).
##
## Keys while running on desktop:
##   F9  cycle device size
##   F10 rotate portrait/landscape

## Real logical point sizes of common devices. Aspect is what matters most;
## the window is scaled down if it would not fit the host screen.
const DEVICES: Array[Vector2i] = [
	Vector2i(375, 667), # iPhone SE
	Vector2i(390, 844), # iPhone 14/15
	Vector2i(430, 932), # iPhone 15 Pro Max
	Vector2i(360, 800), # Galaxy S20
	Vector2i(412, 915), # Pixel 7
	Vector2i(600, 969), # small tablet
	Vector2i(820, 1180), # iPad Air
]
const DEVICE_NAMES: Array[String] = [
	"iPhone SE", "iPhone 14/15", "iPhone 15 Pro Max",
	"Galaxy S20", "Pixel 7", "Tablet 600x969", "iPad Air",
]
const NEXT_KEY := KEY_F9
const ROTATE_KEY := KEY_F10
## Fraction of the host screen height the window may use.
const MAX_SCREEN_FRACTION := 0.85
## Preview windows open at this multiple of the device's logical points, so
## the game renders at phone-like pixel density instead of downscaling the
## 720-wide design canvas (which makes everything blurry on the desktop).
const PREVIEW_DENSITY := 2.0

var _index := 1 # start on iPhone 14/15, closest to a typical target device
var _landscape := false


func _ready() -> void:
	# No-op on phones/tablets/web and in release exports.
	if not OS.has_feature("pc") or not OS.is_debug_build():
		set_process(false)
		set_process_unhandled_key_input(false)
		return
	_apply()


func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.physical_keycode:
			NEXT_KEY:
				_index = (_index + 1) % DEVICES.size()
				_apply()
			ROTATE_KEY:
				_landscape = not _landscape
				_apply()


func _apply() -> void:
	var size := DEVICES[_index] if not _landscape else Vector2i(DEVICES[_index].y, DEVICES[_index].x)
	var screen := DisplayServer.screen_get_usable_rect(DisplayServer.window_get_current_screen())
	# Open at phone pixel density, then shrink to fit the host screen.
	var points := Vector2(size) * PREVIEW_DENSITY
	var fit := minf(1.0, float(screen.size.y) * MAX_SCREEN_FRACTION / points.y)
	var window := get_window()
	window.size = Vector2i(points * fit)
	window.move_to_center()
	window.title = "DropGrid - %s%s (%dx%d)" % [
		DEVICE_NAMES[_index], " landscape" if _landscape else "", size.x, size.y,
	]
