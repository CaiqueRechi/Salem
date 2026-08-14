extends Node2D
class_name InteractiveObject

signal activated(object_id: String)

@export var object_id := ""
@export var display_name := ""
@export var unlocks_action := ""
@export var size := Vector2(76.0, 38.0)
@export var fill_color := Color("#D4A047")
@export var accent_color := Color("#FFECA5")

var _area := Area2D.new()
var _hovered := false
var _hover_amount := 0.0
var _card_style := StyleBoxFlat.new()

func _ready() -> void:
	_card_style.set_border_width_all(1)
	_card_style.set_corner_radius_all(11)
	_setup_area()
	set_process(false)
	queue_redraw()

func _process(delta: float) -> void:
	var target := 1.0 if _hovered else 0.0
	_hover_amount = move_toward(_hover_amount, target, delta * 7.0)
	queue_redraw()
	if is_equal_approx(_hover_amount, target):
		set_process(false)

func configure(id: String, label: String, action: String, color: Color) -> void:
	object_id = id
	display_name = label
	unlocks_action = action
	fill_color = color
	queue_redraw()

func _draw() -> void:
	var lift := -2.5 * _hover_amount
	var rect := Rect2(-size * 0.5 + Vector2(0.0, lift), size)
	draw_circle(Vector2(0.0, size.y * 0.42 + 3.0), size.x * 0.34, Color(0.02, 0.01, 0.03, 0.24 + _hover_amount * 0.08))

	_card_style.bg_color = Color(fill_color.darkened(0.70), 0.88 + _hover_amount * 0.08)
	_card_style.border_color = Color(fill_color, 0.38 + _hover_amount * 0.48)
	draw_style_box(_card_style, rect)

	_draw_icon(Vector2(-22.0, lift), Color(fill_color, 0.90))
	var font := ThemeDB.get_fallback_font()
	draw_string(font, Vector2(-8.0, 4.0 + lift), display_name, HORIZONTAL_ALIGNMENT_LEFT, 42.0, 10, Color(accent_color, 0.76 + _hover_amount * 0.24))

func _draw_icon(origin: Vector2, color: Color) -> void:
	match object_id:
		"laptop":
			draw_rect(Rect2(origin + Vector2(-7.0, -7.0), Vector2(15.0, 11.0)), color, false, 1.4)
			draw_line(origin + Vector2(-10.0, 7.0), origin + Vector2(11.0, 7.0), color, 1.6)
		"cat_bed":
			draw_arc(origin + Vector2(0.0, 4.0), 9.0, PI, TAU, 18, color, 1.6)
			draw_line(origin + Vector2(-9.0, 4.0), origin + Vector2(-9.0, 8.0), color, 1.4)
			draw_line(origin + Vector2(9.0, 4.0), origin + Vector2(9.0, 8.0), color, 1.4)
		_:
			draw_colored_polygon(PackedVector2Array([
				origin + Vector2(-9.0, -5.0), origin + Vector2(0.0, -9.0),
				origin + Vector2(9.0, -5.0), origin + Vector2(7.0, 8.0),
				origin + Vector2(-7.0, 8.0)
			]), Color(color, 0.18))
			draw_polyline(PackedVector2Array([
				origin + Vector2(-9.0, -5.0), origin + Vector2(0.0, -9.0),
				origin + Vector2(9.0, -5.0), origin + Vector2(7.0, 8.0),
				origin + Vector2(-7.0, 8.0), origin + Vector2(-9.0, -5.0)
			]), color, 1.4)

func _setup_area() -> void:
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = size
	collision.shape = shape
	_area.input_pickable = true
	_area.add_child(collision)
	_area.input_event.connect(_on_input_event)
	_area.mouse_entered.connect(func() -> void:
		_hovered = true
		set_process(true)
	)
	_area.mouse_exited.connect(func() -> void:
		_hovered = false
		set_process(true)
	)
	add_child(_area)

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		activated.emit(object_id)
		EventBus.emit_notification("%s is ready." % display_name)
