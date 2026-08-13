extends PanelContainer
class_name DebugPanel

signal mood_requested(mood: String)
signal state_requested(state_id: String)
signal cozy_points_requested(amount: int)
signal random_event_requested(event_id: String)
signal developer_event_requested(event_id: String)
signal save_requested()
signal load_requested()
signal reset_requested()

func _ready() -> void:
	visible = OS.is_debug_build()
	position = Vector2(16, 132)
	if not visible:
		return
	_build()

func _build() -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#1D161F", 0.90)
	style.border_color = Color("#DB633A")
	style.set_border_width_all(2)
	style.set_corner_radius_all(6)
	add_theme_stylebox_override("panel", style)

	var box := VBoxContainer.new()
	box.custom_minimum_size = Vector2(210, 0)
	add_child(box)

	var title := Label.new()
	title.text = "Debug"
	title.add_theme_color_override("font_color", Color("#FFECA5"))
	box.add_child(title)

	var moods := OptionButton.new()
	for mood in ["happy", "sleepy", "playful", "curious", "hungry", "grumpy", "neutral"]:
		moods.add_item(mood)
	moods.item_selected.connect(func(index: int) -> void: mood_requested.emit(moods.get_item_text(index)))
	box.add_child(moods)

	var states := OptionButton.new()
	for state in PetBehaviourConfig.STATES:
		states.add_item(state)
	states.item_selected.connect(func(index: int) -> void: state_requested.emit(states.get_item_text(index)))
	box.add_child(states)

	_add_button(box, "+ Cozy Points", func() -> void: cozy_points_requested.emit(25))
	_add_button(box, "Random: Zoomies", func() -> void: random_event_requested.emit("zoomies"))
	_add_button(box, "Random: Void", func() -> void: random_event_requested.emit("stare_into_void"))
	_add_button(box, "Commit Event", func() -> void: developer_event_requested.emit("commit_created"))
	_add_button(box, "Tests Passed", func() -> void: developer_event_requested.emit("tests_passed"))
	_add_button(box, "Tests Failed", func() -> void: developer_event_requested.emit("tests_failed"))
	_add_button(box, "Break", func() -> void: developer_event_requested.emit("break_recommended"))
	_add_button(box, "Save", save_requested.emit)
	_add_button(box, "Load", load_requested.emit)
	_add_button(box, "Reset", reset_requested.emit)

func _add_button(parent: VBoxContainer, label: String, callable: Callable) -> void:
	var button := Button.new()
	button.text = label
	button.pressed.connect(callable)
	parent.add_child(button)
