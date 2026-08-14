extends Control
class_name WindowChrome

signal close_requested()

const INK := Color("#17131F")
const PLUM := Color("#533D64")
const CORAL := Color("#DB633A")
const GOLD := Color("#D4A047")
const CREAM := Color("#FFECA5")

var _time := 0.0
var _close_button := Button.new()
var _shadow_style: StyleBoxFlat
var _card_style: StyleBoxFlat
var _header_style: StyleBoxFlat

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_index = -100
	_shadow_style = _style(Color(0.02, 0.01, 0.03, 0.46), Color.TRANSPARENT, 0, 18)
	_card_style = _style(Color(INK, 0.97), Color(PLUM, 0.82), 1, 18)
	_header_style = _style(Color(PLUM, 0.14), Color.TRANSPARENT, 0, 17)
	_build_close_button()
	queue_redraw()

func _process(delta: float) -> void:
	_time += delta
	queue_redraw()

func apply_settings(settings) -> void:
	set_process(settings.animations_enabled)
	if not settings.animations_enabled:
		_time = 0.0
		queue_redraw()

func _draw() -> void:
	var canvas_size := size
	if canvas_size.x <= 0.0 or canvas_size.y <= 0.0:
		canvas_size = get_viewport_rect().size

	var shadow_rect := Rect2(10.0, 13.0, canvas_size.x - 20.0, canvas_size.y - 20.0)
	draw_style_box(_shadow_style, shadow_rect)

	var card_rect := Rect2(7.0, 7.0, canvas_size.x - 14.0, canvas_size.y - 17.0)
	draw_style_box(_card_style, card_rect)

	# Slow moving glows keep the window alive without competing with Salem.
	var drift := sin(_time * 0.42)
	draw_circle(Vector2(canvas_size.x - 54.0 + drift * 7.0, canvas_size.y - 38.0), 72.0, Color(PLUM, 0.10))
	draw_circle(Vector2(36.0 - drift * 4.0, canvas_size.y - 18.0), 46.0, Color(CORAL, 0.055))
	draw_arc(Vector2(canvas_size.x - 58.0, canvas_size.y - 43.0), 48.0 + drift * 2.0, 0.0, TAU, 48, Color(GOLD, 0.08), 1.0)

	var header_rect := Rect2(8.0, 8.0, canvas_size.x - 16.0, 39.0)
	draw_style_box(_header_style, header_rect)
	draw_line(Vector2(16.0, 47.0), Vector2(canvas_size.x - 16.0, 47.0), Color(PLUM, 0.36), 1.0)

	var font := ThemeDB.get_fallback_font()
	draw_string(font, Vector2(19.0, 32.0), "SALEM.EXE", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 16, CREAM)
	draw_string(font, Vector2(116.0, 30.0), "COZY COMPANION", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 10, Color(CREAM, 0.46))

	var pulse := 3.4 + sin(_time * 2.0) * 0.7
	draw_circle(Vector2(canvas_size.x - 100.0, 27.0), pulse + 3.0, Color(GOLD, 0.08))
	draw_circle(Vector2(canvas_size.x - 100.0, 27.0), pulse, GOLD)
	draw_string(font, Vector2(canvas_size.x - 89.0, 30.5), "AWAKE", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 9, Color(CREAM, 0.62))

	for index in range(5):
		var x := 24.0 + float(index) * 72.0
		var y := canvas_size.y - 19.0 + sin(_time * 0.7 + float(index)) * 1.5
		draw_circle(Vector2(x, y), 1.2, Color(CREAM, 0.12))

func _build_close_button() -> void:
	_close_button.text = "\u00d7"
	_close_button.tooltip_text = "Close Salem"
	_close_button.focus_mode = Control.FOCUS_NONE
	_close_button.mouse_filter = Control.MOUSE_FILTER_STOP
	_close_button.z_as_relative = false
	_close_button.z_index = 100
	_close_button.anchor_left = 1.0
	_close_button.anchor_right = 1.0
	_close_button.offset_left = -45.0
	_close_button.offset_right = -14.0
	_close_button.offset_top = 12.0
	_close_button.offset_bottom = 43.0
	_close_button.add_theme_font_size_override("font_size", 20)
	_close_button.add_theme_color_override("font_color", Color(CREAM, 0.78))
	_close_button.add_theme_color_override("font_hover_color", Color.WHITE)
	_close_button.add_theme_stylebox_override("normal", _style(Color(PLUM, 0.18), Color(PLUM, 0.46), 1, 10))
	_close_button.add_theme_stylebox_override("hover", _style(Color(CORAL, 0.88), Color(CREAM, 0.45), 1, 10))
	_close_button.add_theme_stylebox_override("pressed", _style(Color(CORAL, 0.64), Color(CREAM, 0.28), 1, 10))
	_close_button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	_close_button.pressed.connect(close_requested.emit)
	add_child(_close_button)

func _style(fill: Color, border: Color, border_width: int, radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(radius)
	return style
