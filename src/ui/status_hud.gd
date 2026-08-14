extends Control
class_name StatusHud

const PLUM := Color("#533D64")
const CORAL := Color("#DB633A")
const GOLD := Color("#D4A047")
const CREAM := Color("#FFECA5")

var _points_label := Label.new()
var _mood_label := Label.new()
var _mood_pill := PanelContainer.new()
var _notification := Label.new()
var _notification_panel := PanelContainer.new()
var _notification_tween: Tween

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_index = 20
	_build()
	EventBus.cozy_points_changed.connect(_on_points_changed)
	EventBus.pet_mood_changed.connect(_on_mood_changed)
	EventBus.notification_requested.connect(show_notification)

func set_values(points: int, mood: String) -> void:
	_on_points_changed(points, 0)
	_on_mood_changed("", mood)

func show_notification(message: String) -> void:
	_notification.text = message
	_notification_panel.visible = true
	_notification_panel.modulate.a = 0.0
	_notification_panel.position.y = 58.0
	if _notification_tween != null:
		_notification_tween.kill()
	_notification_tween = create_tween()
	_notification_tween.set_parallel(true)
	_notification_tween.set_trans(Tween.TRANS_QUAD)
	_notification_tween.set_ease(Tween.EASE_OUT)
	_notification_tween.tween_property(_notification_panel, "modulate:a", 1.0, 0.18)
	_notification_tween.tween_property(_notification_panel, "position:y", 54.0, 0.22)
	_notification_tween.set_parallel(false)
	_notification_tween.tween_interval(2.15)
	_notification_tween.tween_property(_notification_panel, "modulate:a", 0.0, 0.45)
	_notification_tween.tween_callback(func() -> void: _notification_panel.visible = false)

func _build() -> void:
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	var points_pill := _make_pill(Rect2(17.0, 54.0, 91.0, 29.0), Color(GOLD, 0.24), Color(GOLD, 0.52))
	root.add_child(points_pill)
	_points_label.text = "COZY  0"
	_prepare_label(_points_label, GOLD)
	points_pill.add_child(_points_label)

	_mood_pill = _make_pill(Rect2(115.0, 54.0, 92.0, 29.0), Color(PLUM, 0.30), Color(PLUM, 0.62))
	root.add_child(_mood_pill)
	_prepare_label(_mood_label, CREAM)
	_mood_pill.add_child(_mood_label)

	_notification_panel = _make_pill(Rect2(214.0, 54.0, 188.0, 29.0), Color(PLUM, 0.38), Color(CORAL, 0.40))
	_notification_panel.visible = false
	root.add_child(_notification_panel)
	_notification.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_notification.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	_prepare_label(_notification, Color(CREAM, 0.88))
	_notification_panel.add_child(_notification)

	_on_points_changed(0, 0)
	_on_mood_changed("", "neutral")

func _make_pill(rect: Rect2, fill: Color, border: Color) -> PanelContainer:
	var pill := PanelContainer.new()
	pill.position = rect.position
	pill.size = rect.size
	pill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(11)
	style.content_margin_left = 10.0
	style.content_margin_right = 10.0
	style.content_margin_top = 5.0
	style.content_margin_bottom = 5.0
	pill.add_theme_stylebox_override("panel", style)
	return pill

func _prepare_label(label: Label, color: Color) -> void:
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override("font_size", 10)
	label.add_theme_color_override("font_color", color)

func _on_points_changed(total: int, _delta: int) -> void:
	_points_label.text = "COZY  %d" % total

func _on_mood_changed(_previous_mood: String, next_mood: String) -> void:
	_mood_label.text = "\u2022  %s" % next_mood.to_upper()
	var mood_color := _color_for_mood(next_mood)
	_mood_label.add_theme_color_override("font_color", mood_color)
	var style := _mood_pill.get_theme_stylebox("panel").duplicate() as StyleBoxFlat
	style.border_color = Color(mood_color, 0.54)
	style.bg_color = Color(mood_color, 0.10)
	_mood_pill.add_theme_stylebox_override("panel", style)

func _color_for_mood(mood: String) -> Color:
	match mood:
		"happy", "playful":
			return GOLD
		"grumpy", "hungry":
			return CORAL
		"sleepy":
			return Color("#A99DD8")
		"curious":
			return Color("#DFA8E8")
		_:
			return Color(CREAM, 0.74)
