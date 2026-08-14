extends Node
class_name DesktopWindowManager

var _window: Window
var _interactive_polygon := PackedVector2Array()
var _dragging := false
var _drag_moved := false
var _drag_start_mouse := Vector2i.ZERO
var _drag_start_window := Vector2i.ZERO

func configure(window: Window, settings) -> void:
	_window = window
	_window.borderless = true
	_window.transparent = true
	_window.always_on_top = settings.always_on_top
	_window.unresizable = true
	_window.min_size = Vector2i(220, 160)
	get_viewport().transparent_bg = true
	set_mouse_passthrough(settings.mouse_passthrough_enabled)
	AppLog.info(AppLog.Category.WINDOW, "Desktop overlay configured.")

func apply_settings(settings) -> void:
	if _window == null:
		return
	_window.always_on_top = settings.always_on_top
	set_mouse_passthrough(settings.mouse_passthrough_enabled)

func set_position(position: Vector2i) -> void:
	if _window == null:
		return
	_window.position = position

func get_position() -> Vector2i:
	if _window == null:
		return Vector2i.ZERO
	return _window.position

func begin_drag() -> void:
	if _window == null:
		return
	_dragging = true
	_drag_moved = false
	_drag_start_mouse = DisplayServer.mouse_get_position()
	_drag_start_window = _window.position

func update_drag() -> void:
	if not _dragging or _window == null:
		return
	var mouse_delta := DisplayServer.mouse_get_position() - _drag_start_mouse
	if mouse_delta.length_squared() < 16:
		return
	_drag_moved = true
	_window.position = _drag_start_window + mouse_delta

func end_drag() -> bool:
	var moved := _drag_moved
	_dragging = false
	_drag_moved = false
	return moved

func is_dragging() -> bool:
	return _dragging

func set_mouse_passthrough(enabled: bool) -> void:
	if _window == null:
		return
	if enabled and _interactive_polygon.size() > 2:
		_window.mouse_passthrough_polygon = _interactive_polygon
		AppLog.info(AppLog.Category.WINDOW, "Selective mouse passthrough enabled.")
	else:
		_window.mouse_passthrough_polygon = PackedVector2Array()

func set_interactive_region(rect: Rect2) -> void:
	_interactive_polygon = PackedVector2Array([
		rect.position,
		rect.position + Vector2(rect.size.x, 0.0),
		rect.position + rect.size,
		rect.position + Vector2(0.0, rect.size.y)
	])
