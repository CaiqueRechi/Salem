extends Node2D
class_name InteractiveObject

signal activated(object_id: String)

@export var object_id := ""
@export var display_name := ""
@export var unlocks_action := ""
@export var size := Vector2(54, 32)
@export var fill_color := Color("#D4A047")
@export var accent_color := Color("#1D161F")

var _area := Area2D.new()

func _ready() -> void:
	_setup_area()
	queue_redraw()

func configure(id: String, label: String, action: String, color: Color) -> void:
	object_id = id
	display_name = label
	unlocks_action = action
	fill_color = color
	queue_redraw()

func _draw() -> void:
	var font := ThemeDB.get_fallback_font()
	draw_rect(Rect2(-size * 0.5, size), fill_color, true)
	draw_rect(Rect2(-size * 0.5, size), accent_color, false, 2.0)
	draw_string(font, Vector2(-size.x * 0.45, 6.0), display_name, HORIZONTAL_ALIGNMENT_LEFT, size.x * 0.9, 10, accent_color)

func _setup_area() -> void:
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = size
	collision.shape = shape
	_area.input_pickable = true
	_area.add_child(collision)
	_area.input_event.connect(_on_input_event)
	add_child(_area)

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		activated.emit(object_id)
		EventBus.emit_notification("%s is ready." % display_name)
