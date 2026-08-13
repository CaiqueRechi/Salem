extends PanelContainer
class_name InteractionMenu

signal action_selected(action_id: String)
signal settings_requested()

func _ready() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#1D161F", 0.94)
	style.border_color = Color("#D4A047")
	style.set_border_width_all(2)
	style.set_corner_radius_all(6)
	add_theme_stylebox_override("panel", style)

	var container := VBoxContainer.new()
	container.add_theme_constant_override("separation", 4)
	add_child(container)

	_add_button(container, "Pet", "pet")
	_add_button(container, "Feed", "feed")
	_add_button(container, "Play", "play")
	_add_button(container, "Pick Up", "pickup")
	_add_button(container, "Settings", "settings")

func show_at(screen_position: Vector2) -> void:
	position = screen_position
	visible = true

func _add_button(parent: VBoxContainer, label: String, action_id: String) -> void:
	var button := Button.new()
	button.text = label
	button.custom_minimum_size = Vector2(104, 28)
	button.add_theme_color_override("font_color", Color("#FFECA5"))
	button.pressed.connect(func() -> void:
		visible = false
		if action_id == "settings":
			settings_requested.emit()
		else:
			action_selected.emit(action_id)
	)
	parent.add_child(button)
