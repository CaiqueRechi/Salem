extends PanelContainer
class_name InteractionMenu

signal action_selected(action_id: String)
signal settings_requested()

const PLUM := Color("#533D64")
const CORAL := Color("#DB633A")
const GOLD := Color("#D4A047")
const CREAM := Color("#FFECA5")

var _requested_position := Vector2.ZERO

func _ready() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	z_index = 50
	var style := _panel_style()
	add_theme_stylebox_override("panel", style)

	var container := VBoxContainer.new()
	container.add_theme_constant_override("separation", 5)
	add_child(container)

	var eyebrow := Label.new()
	eyebrow.text = "A LITTLE MOMENT WITH SALEM"
	eyebrow.add_theme_font_size_override("font_size", 9)
	eyebrow.add_theme_color_override("font_color", Color(GOLD, 0.70))
	container.add_child(eyebrow)

	_add_button(container, "Give Salem a pet", "pet", GOLD)
	_add_button(container, "Offer a snack", "feed", CORAL)
	_add_button(container, "Play for a bit", "play", PLUM.lightened(0.25))
	_add_button(container, "Move together", "pickup", CREAM.darkened(0.25))
	_add_button(container, "Open settings", "settings", Color(CREAM, 0.55))

func show_at(screen_position: Vector2) -> void:
	_requested_position = screen_position
	visible = true
	modulate.a = 0.0
	scale = Vector2(0.95, 0.95)
	call_deferred("_place_and_animate")

func _place_and_animate() -> void:
	var viewport_size := get_viewport_rect().size
	position = Vector2(
		clampf(_requested_position.x, 12.0, maxf(12.0, viewport_size.x - size.x - 12.0)),
		clampf(_requested_position.y, 52.0, maxf(52.0, viewport_size.y - size.y - 12.0))
	)
	pivot_offset = size * 0.5
	var tween := create_tween().set_parallel(true)
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2.ONE, 0.20)
	tween.tween_property(self, "modulate:a", 1.0, 0.14)

func _add_button(parent: VBoxContainer, label: String, action_id: String, accent: Color) -> void:
	var button := Button.new()
	button.text = label
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.custom_minimum_size = Vector2(176.0, 29.0)
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_size_override("font_size", 11)
	button.add_theme_color_override("font_color", Color(CREAM, 0.86))
	button.add_theme_color_override("font_hover_color", CREAM)
	button.add_theme_stylebox_override("normal", _button_style(Color(PLUM, 0.12), Color(PLUM, 0.24)))
	button.add_theme_stylebox_override("hover", _button_style(Color(accent, 0.18), Color(accent, 0.58)))
	button.add_theme_stylebox_override("pressed", _button_style(Color(accent, 0.28), Color(accent, 0.42)))
	button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	button.pressed.connect(func() -> void:
		visible = false
		if action_id == "settings":
			settings_requested.emit()
		else:
			action_selected.emit(action_id)
	)
	parent.add_child(button)

func _panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#211927", 0.98)
	style.border_color = Color(PLUM, 0.86)
	style.set_border_width_all(1)
	style.set_corner_radius_all(14)
	style.set_content_margin_all(12.0)
	return style

func _button_style(fill: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(8)
	style.content_margin_left = 10.0
	style.content_margin_right = 8.0
	return style
