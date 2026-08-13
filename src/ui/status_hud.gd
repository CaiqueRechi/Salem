extends CanvasLayer
class_name StatusHud

var _points_label := Label.new()
var _mood_label := Label.new()
var _notification := Label.new()
var _notification_tween: Tween

func _ready() -> void:
	_build()
	EventBus.cozy_points_changed.connect(_on_points_changed)
	EventBus.pet_mood_changed.connect(_on_mood_changed)
	EventBus.notification_requested.connect(show_notification)

func show_notification(message: String) -> void:
	_notification.text = message
	_notification.modulate.a = 1.0
	if _notification_tween != null:
		_notification_tween.kill()
	_notification_tween = create_tween()
	_notification_tween.tween_interval(2.0)
	_notification_tween.tween_property(_notification, "modulate:a", 0.0, 0.7)

func _build() -> void:
	var root := Control.new()
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	_points_label.position = Vector2(12, 8)
	_points_label.add_theme_color_override("font_color", Color("#FFECA5"))
	root.add_child(_points_label)

	_mood_label.position = Vector2(12, 28)
	_mood_label.add_theme_color_override("font_color", Color("#D4A047"))
	root.add_child(_mood_label)

	_notification.position = Vector2(12, 52)
	_notification.add_theme_color_override("font_color", Color("#FFECA5"))
	_notification.modulate.a = 0.0
	root.add_child(_notification)

	_on_points_changed(0, 0)
	_on_mood_changed("", "neutral")

func _on_points_changed(total: int, _delta: int) -> void:
	_points_label.text = "Cozy %d" % total

func _on_mood_changed(_previous_mood: String, next_mood: String) -> void:
	_mood_label.text = next_mood.capitalize()
