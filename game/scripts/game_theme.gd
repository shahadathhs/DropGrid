class_name GameTheme
extends Theme
## The one shared Theme for the whole game, built from the prototype tokens.
## Colors come from Palette. Sizes are the prototype's CSS pixel values times UI_SCALE.
## Scenes pick a look by name, for example theme_type_variation = &"PrimaryButton".
## project.godot points gui/theme/custom at this theme, so every Control inherits it.

## 720 px wide is about 480 prototype CSS px, so one CSS px is 1.5 Godot px.
const UI_SCALE := 1.5

## Corner radii from the prototype (CSS px 8 / 12 / 16 / 24), times UI_SCALE.
const RADIUS_SM := 12
const RADIUS_MD := 18
const RADIUS_LG := 24
const RADIUS_XL := 36
const RADIUS_PILL := 200

## Body text size: the prototype body is 14 CSS px.
const FONT_BODY := 21

## Bold weight used for headings, buttons, and "strong" labels.
var _bold_font: Font


func _init() -> void:
	_set_fonts()
	set_color("font_color", "Label", Palette.TEXT)
	_set_label_variations()
	_set_button_variations()
	_set_panel_variations()
	_set_input_and_progress()


## Fonts: the prototype uses the system UI font stack, so this uses the system font too
## (SystemFont). The project has no bundled font, so Godot's default font is the fallback.
func _set_fonts() -> void:
	var regular := SystemFont.new()
	regular.font_names = PackedStringArray(["Helvetica Neue", "Segoe UI", "Roboto", "Arial"])
	regular.font_weight = 400
	default_font = regular
	default_font_size = FONT_BODY

	# Bold: a fake-bold of the regular face (variation_embolden). Godot's SystemFont
	# weight is not applied on every platform, so this is the reliable option.
	var bold := FontVariation.new()
	bold.base_font = regular
	bold.variation_embolden = 0.9
	_bold_font = bold


## Label variations. Use with theme_type_variation on a Label.
func _set_label_variations() -> void:
	# Small uppercase label above headings (prototype .eyebrow: 10 px, bold, muted).
	_make_label_type("Eyebrow", 15, Palette.TEXT_MUTED, true)
	# Captions for stat cards and form fields (prototype 9-10 px bold uppercase).
	_make_label_type("Caption", 14, Palette.TEXT_MUTED, true)
	# Secondary copy (prototype 13-14 px muted).
	_make_label_type("Muted", 20, Palette.TEXT_MUTED, false)
	# Tiny faint copy: version line and legal note.
	_make_label_type("Faint", 16, Palette.TEXT_FAINT, false)
	# Brand wordmark (prototype .brand: 12 px, weight 800, uppercase).
	_make_label_type("Brand", 18, Palette.TEXT, true)
	# Top bar title (prototype .topbar strong: 14 px).
	_make_label_type("Title", 24, Palette.TEXT, true)
	# Hero heading, for example "Find your" (prototype .menu-hero h1: 44 px).
	_make_label_type("Display", 66, Palette.TEXT, true)
	# Second word of the hero heading, in accent color ("flow.").
	_make_label_type("DisplayAccent", 66, Palette.ACCENT, true)
	# Section heading (prototype h2: 26-32 px, weight 800).
	_make_label_type("Heading", 45, Palette.TEXT, true)
	# Accent half of a section heading, for example "on top?".
	_make_label_type("HeadingAccent", 45, Palette.ACCENT, true)
	# Stat numbers (prototype .stat strong: 17 px).
	_make_label_type("Value", 27, Palette.TEXT, true)
	# Personal best on the menu, and the profile name (prototype 22 px).
	_make_label_type("Best", 33, Palette.TEXT, true)
	# Big score number on the game over screen (prototype .score-card strong: 32 px).
	_make_label_type("BigValue", 48, Palette.TEXT, true)
	# Live score in the game header (prototype 18 px).
	_make_label_type("LiveScore", 27, Palette.TEXT, true)
	# Small "Best" value in the game header (prototype 12 px, muted).
	_make_label_type("MiniValue", 18, Palette.TEXT_MUTED, true)
	# Danger-colored text.
	_make_label_type("Danger", 20, Palette.DANGER, false)
	# Level pill text (prototype .level-pill: 9 px bold, accent).
	_make_label_type("Pill", 15, Palette.ACCENT, true)
	# Field error line and the form error box text (prototype .form-error).
	_make_label_type("FormError", 19, Palette.DANGER, false)
	# Avatar initials (prototype .avatar: 13 px bold, accent).
	_make_label_type("Avatar", 25, Palette.ACCENT, true)
	# Text inside buttons that have an icon (see the icon rows in the scenes).
	_make_label_type("PrimaryLabel", 21, Palette.ACCENT_INK, true)
	_make_label_type("SecondaryLabel", 21, Palette.TEXT, true)
	_make_label_type("GhostLabel", 20, Palette.TEXT_MUTED, true)


func _make_label_type(type_name: String, size: int, color: Color, bold: bool) -> void:
	set_type_variation(type_name, "Label")
	set_font_size("font_size", type_name, size)
	set_color("font_color", type_name, color)
	if bold:
		set_font("font", type_name, _bold_font)


## Buttons. Primary and secondary follow the prototype's .btn-primary and .btn-secondary.
func _set_button_variations() -> void:
	# Base look for every Button.
	set_font_size("font_size", "Button", FONT_BODY)
	set_color("font_color", "Button", Palette.TEXT)
	set_color("font_hover_color", "Button", Palette.TEXT)
	set_color("font_pressed_color", "Button", Palette.TEXT)
	set_color("font_disabled_color", "Button", Palette.TEXT_FAINT)
	set_color("icon_normal_color", "Button", Palette.TEXT)
	set_color("icon_hover_color", "Button", Palette.TEXT)
	set_color("icon_pressed_color", "Button", Palette.TEXT)
	set_color("icon_disabled_color", "Button", Palette.TEXT_FAINT)
	set_constant("h_separation", "Button", 12)
	set_constant("icon_max_width", "Button", 26)
	set_font("font", "Button", _bold_font)
	set_stylebox("focus", "Button", _box(Color(0, 0, 0, 0), RADIUS_MD, Palette.ACCENT, 3))

	# Primary: accent fill with dark ink text (prototype .btn-primary).
	_make_button_type("PrimaryButton", Palette.ACCENT, Palette.ACCENT_INK, Color(0, 0, 0, 0), 0, RADIUS_MD, 21)
	# Secondary: surface-2 fill with a strong border (prototype .btn-secondary).
	_make_button_type("SecondaryButton", Palette.SURFACE_2, Palette.TEXT, Palette.LINE_STRONG, 2, RADIUS_MD, 21)
	# Ghost: no fill, muted text that turns to ink on hover (prototype .btn-ghost).
	_make_button_type("GhostButton", Color(0, 0, 0, 0), Palette.TEXT_MUTED, Color(0, 0, 0, 0), 0, RADIUS_MD, 20)
	# Text: no fill, muted (prototype .btn-text).
	_make_button_type("TextButton", Color(0, 0, 0, 0), Palette.TEXT_MUTED, Color(0, 0, 0, 0), 0, RADIUS_MD, 20)
	# Quiet text: the faint "Quit to home" link (prototype .btn-text.quiet).
	_make_button_type("QuietButton", Color(0, 0, 0, 0), Palette.TEXT_FAINT, Color(0, 0, 0, 0), 0, RADIUS_MD, 18)
	# Danger text: "Delete account" link (prototype .danger-text).
	_make_button_type("DangerTextButton", Color(0, 0, 0, 0), Palette.DANGER, Color(0, 0, 0, 0), 0, RADIUS_MD, 20)
	# Danger filled: the confirm delete button (prototype .danger-btn).
	_make_button_type("DangerButton", Palette.DANGER_SOFT, Palette.DANGER, Palette.DANGER_LINE, 2, RADIUS_MD, 21)
	# Icon button: square, surface-2 with a thin line border (prototype .icon-btn).
	_make_button_type("IconButton", Palette.SURFACE_2, Palette.TEXT, Palette.LINE, 2, RADIUS_MD, 21)
	# Game control keys (prototype .controls button).
	_make_button_type("ControlButton", Palette.SURFACE_2, Palette.TEXT, Palette.LINE, 2, RADIUS_MD, 21)
	# Hard drop key: warning colored (prototype .controls button.drop).
	_make_button_type("DropButton", Color("241F14"), Palette.WARNING, Color("4A3F24"), 2, RADIUS_MD, 21)
	# Segment tab (prototype .segmented button). The pressed style is the selected tab.
	_make_button_type("SegmentButton", Color(0, 0, 0, 0), Palette.TEXT_MUTED, Color(0, 0, 0, 0), 0, RADIUS_SM, 20)
	set_stylebox("pressed", "SegmentButton", _box(Palette.SURFACE_3, RADIUS_SM, Color(0, 0, 0, 0), 0))
	set_stylebox("hover_pressed", "SegmentButton", _box(Palette.SURFACE_3, RADIUS_SM, Color(0, 0, 0, 0), 0))
	set_color("font_pressed_color", "SegmentButton", Palette.TEXT)
	set_color("font_hover_pressed_color", "SegmentButton", Palette.TEXT)
	# Card button (prototype .setting-row, .hub-links button). Its content sits in child
	# containers that ignore the mouse, so the whole card can be pressed.
	_make_button_type("CardButton", Palette.SURFACE, Palette.TEXT, Palette.LINE, 2, RADIUS_MD, 21)
	set_stylebox("hover", "CardButton", _box(Palette.SURFACE, RADIUS_MD, Palette.LINE_STRONG, 2))


## Builds one button variation. Heights are not set here: each node sets custom_minimum_size.
func _make_button_type(type_name: String, fill: Color, text_color: Color, border: Color, border_width: int, radius: int, font_size: int) -> void:
	set_type_variation(type_name, "Button")
	set_color("font_color", type_name, text_color)
	set_color("font_hover_color", type_name, text_color)
	set_color("font_pressed_color", type_name, text_color)
	set_color("font_focus_color", type_name, text_color)
	set_color("font_disabled_color", type_name, Color(text_color, 0.45))
	set_color("icon_normal_color", type_name, text_color)
	set_color("icon_hover_color", type_name, text_color)
	set_color("icon_pressed_color", type_name, text_color)
	set_color("icon_disabled_color", type_name, Color(text_color, 0.45))
	set_font_size("font_size", type_name, font_size)
	set_font("font", type_name, _bold_font)
	var normal := _box(fill, radius, border, border_width)
	# Pressed brightens the fill a little (prototype: filter brightness 1.12 while active).
	var pressed := _box(fill.lightened(0.12), radius, border, border_width)
	var disabled := _box(Color(fill, fill.a * 0.45), radius, Color(border, border.a * 0.45), border_width)
	set_stylebox("normal", type_name, normal)
	set_stylebox("hover", type_name, normal)
	set_stylebox("pressed", type_name, pressed)
	set_stylebox("hover_pressed", type_name, pressed)
	set_stylebox("disabled", type_name, disabled)
	set_stylebox("focus", type_name, _box(Color(0, 0, 0, 0), radius, Palette.ACCENT, 3))
	# Horizontal padding inside the button, so the label is not against the edge.
	for style_name in ["normal", "hover", "pressed", "hover_pressed", "disabled", "focus"]:
		var box := get_stylebox(style_name, type_name) as StyleBoxFlat
		box.content_margin_left = 27
		box.content_margin_right = 27


## Panels and cards: prototype .stat, .score-card, .confirm-panel, .pause-panel, and friends.
func _set_panel_variations() -> void:
	# Full-screen background (prototype .screen-* background).
	set_type_variation("ScreenBackground", "Panel")
	set_stylebox("panel", "ScreenBackground", _box(Palette.BACKGROUND, 0, Color(0, 0, 0, 0), 0))

	# Dim layer behind the pause panel (prototype: the board is dimmed while paused).
	set_type_variation("DimLayer", "Panel")
	set_stylebox("panel", "DimLayer", _box(Color(Palette.BACKGROUND, 0.78), 0, Color(0, 0, 0, 0), 0))

	# Stat card (prototype .stat): surface with a thin line border.
	set_type_variation("StatCard", "PanelContainer")
	set_stylebox("panel", "StatCard", _box(Palette.SURFACE, RADIUS_SM, Palette.LINE, 2, 18, 15))

	# Card with a stronger border (prototype .score-card, .confirm-panel).
	set_type_variation("StrongCard", "PanelContainer")
	set_stylebox("panel", "StrongCard", _box(Palette.SURFACE, RADIUS_LG, Palette.LINE_STRONG, 2, 24, 22))

	# Pause panel (prototype .pause-panel): slightly see-through, very rounded.
	set_type_variation("PausePanel", "PanelContainer")
	set_stylebox("panel", "PausePanel", _box(Palette.PANEL, RADIUS_XL, Palette.LINE_STRONG, 2, 33, 30))

	# Segmented control wrapper (prototype .segmented).
	set_type_variation("SegmentedBox", "PanelContainer")
	set_stylebox("panel", "SegmentedBox", _box(Palette.SURFACE, RADIUS_MD, Palette.LINE, 2, 6, 6))

	# Form error box (prototype .form-error).
	set_type_variation("FormErrorBox", "PanelContainer")
	set_stylebox("panel", "FormErrorBox", _box(Palette.DANGER_SOFT, RADIUS_SM, Palette.DANGER_LINE, 2, 18, 12))

	# Leaderboard row (prototype .lb-row) and the signed-in player's row (.lb-row.me).
	set_type_variation("LeaderRow", "PanelContainer")
	set_stylebox("panel", "LeaderRow", _box(Palette.SURFACE, RADIUS_SM, Palette.LINE, 2, 18, 12))
	set_type_variation("LeaderRowMe", "PanelContainer")
	set_stylebox("panel", "LeaderRowMe", _box(Palette.ACCENT_SOFT, RADIUS_SM, Palette.ACCENT_ROW_BORDER, 2, 18, 12))

	# Round avatar (prototype .avatar): accent-soft circle.
	set_type_variation("AvatarCircle", "PanelContainer")
	set_stylebox("panel", "AvatarCircle", _box(Palette.ACCENT_SOFT, RADIUS_PILL, Color(0, 0, 0, 0), 0))

	# Small rounded square behind a panel icon (prototype .panel-mark).
	set_type_variation("IconTile", "PanelContainer")
	set_stylebox("panel", "IconTile", _box(Palette.ACCENT_SOFT, RADIUS_MD, Color(0, 0, 0, 0), 0))

	# Settings icon tile (prototype .setting-icon).
	set_type_variation("SettingIcon", "PanelContainer")
	set_stylebox("panel", "SettingIcon", _box(Palette.SURFACE_3, RADIUS_SM, Color(0, 0, 0, 0), 0))

	# Level pill (prototype .level-pill): soft accent with a border.
	set_type_variation("LevelPill", "PanelContainer")
	set_stylebox("panel", "LevelPill", _box(Palette.ACCENT_SOFT, 12, Palette.ACCENT_BORDER, 2, 15, 6))

	# Toggle track (prototype .toggle): surface-3 when off, accent when on. The knob is a child.
	set_type_variation("ToggleOff", "Panel")
	set_stylebox("panel", "ToggleOff", _box(Palette.SURFACE_3, RADIUS_PILL, Color(0, 0, 0, 0), 0))
	set_type_variation("ToggleOn", "Panel")
	set_stylebox("panel", "ToggleOn", _box(Palette.ACCENT, RADIUS_PILL, Color(0, 0, 0, 0), 0))
	# Toggle knob (prototype .toggle i): muted when off, bright when on.
	set_type_variation("ToggleKnobOff", "Panel")
	set_stylebox("panel", "ToggleKnobOff", _box(Palette.TEXT_MUTED, RADIUS_PILL, Color(0, 0, 0, 0), 0))
	set_type_variation("ToggleKnobOn", "Panel")
	set_stylebox("panel", "ToggleKnobOn", _box(Palette.TEXT, RADIUS_PILL, Color(0, 0, 0, 0), 0))


## Text inputs (prototype .input-shell) and the progress bar (prototype .progress-line .track).
func _set_input_and_progress() -> void:
	set_stylebox("normal", "LineEdit", _box(Palette.SURFACE, RADIUS_MD, Palette.LINE_STRONG, 2, 21, 0))
	set_stylebox("focus", "LineEdit", _box(Palette.SURFACE, RADIUS_MD, Palette.ACCENT, 2, 21, 0))
	set_stylebox("read_only", "LineEdit", _box(Palette.SURFACE, RADIUS_MD, Palette.LINE, 2, 21, 0))
	set_color("font_color", "LineEdit", Palette.TEXT)
	set_color("font_placeholder_color", "LineEdit", Palette.TEXT_FAINT)
	set_color("caret_color", "LineEdit", Palette.ACCENT)
	set_color("selection_color", "LineEdit", Palette.ACCENT_SOFT)
	set_font_size("font_size", "LineEdit", FONT_BODY)

	# Progress track: surface-2 with a mint fill.
	set_stylebox("background", "ProgressBar", _box(Palette.SURFACE_2, 4, Color(0, 0, 0, 0), 0))
	set_stylebox("fill", "ProgressBar", _box(Palette.SUCCESS, 4, Color(0, 0, 0, 0), 0))


## Builds a rounded box. Radius and padding are in Godot pixels (see the constants above).
func _box(fill: Color, radius: int, border: Color, border_width: int, pad_x: int = 0, pad_y: int = 0) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = fill
	box.set_corner_radius_all(radius)
	box.set_border_width_all(border_width)
	box.border_color = border
	box.content_margin_left = pad_x
	box.content_margin_right = pad_x
	box.content_margin_top = pad_y
	box.content_margin_bottom = pad_y
	box.anti_aliasing = true
	return box
