extends PanelContainer
class_name DebugPanel

const PetBehaviourConfig = preload("res://src/pet/pet_behaviour_config.gd")

signal mood_requested(mood: String)
signal state_requested(state_id: String)
signal cozy_points_requested(amount: int)
signal random_event_requested(event_id: String)
signal developer_event_requested(event_id: String)
signal save_requested()
signal load_requested()
signal reset_requested()

func _ready() -> void:
	visible = false
	if not OS.is_debug_build():
		set_process_input(false)
		return
	position = Vector2(190, 54)
	z_index = 70
	_build()
	set_process_input(true)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.keycode == KEY_F12 and event.pressed and not event.echo:
		visible = not visible
		get_viewport().set_input_as_handled()

func _build() -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#1D161F", 0.90)
	style.border_color = Color("#DB633A")
	style.set_border_width_all(2)
	style.set_corner_radius_all(6)
	add_theme_stylebox_override("panel", style)

	var box := VBoxContainer.new()
	box.custom_minimum_size = Vector2(214, 0)
	box.add_theme_constant_override("separation", 4)
	add_child(box)

	var title := Label.new()
	title.text = "Debug"
	title.add_theme_color_override("font_color", Color("#FFECA5"))
	box.add_child(title)

	var selectors := HBoxContainer.new()
	selectors.add_theme_constant_override("separation", 4)
	box.add_child(selectors)

	var moods := OptionButton.new()
	moods.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for mood in ["happy", "sleepy", "playful", "curious", "hungry", "grumpy", "neutral"]:
		moods.add_item(mood)
	moods.item_selected.connect(func(index: int) -> void: mood_requested.emit(moods.get_item_text(index)))
	selectors.add_child(moods)

	var states := OptionButton.new()
	states.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for state in PetBehaviourConfig.STATES:
		states.add_item(state)
	states.item_selected.connect(func(index: int) -> void: state_requested.emit(states.get_item_text(index)))
	selectors.add_child(states)

	var actions := GridContainer.new()
	actions.columns = 2
	actions.add_theme_constant_override("h_separation", 4)
	actions.add_theme_constant_override("v_separation", 3)
	box.add_child(actions)
	_add_button(actions, "+ Cozy", func() -> void: cozy_points_requested.emit(25))
	_add_button(actions, "Zoomies", func() -> void: random_event_requested.emit("zoomies"))
	_add_button(actions, "Void", func() -> void: random_event_requested.emit("stare_into_void"))
	_add_button(actions, "Commit", func() -> void: developer_event_requested.emit("commit_created"))
	_add_button(actions, "Tests OK", func() -> void: developer_event_requested.emit("tests_passed"))
	_add_button(actions, "Tests fail", func() -> void: developer_event_requested.emit("tests_failed"))
	_add_button(actions, "Break", func() -> void: developer_event_requested.emit("break_recommended"))
	_add_button(actions, "Save", save_requested.emit)
	_add_button(actions, "Load", load_requested.emit)
	_add_button(actions, "Reset", reset_requested.emit)

func _add_button(parent: Container, label: String, callable: Callable) -> void:
	var button := Button.new()
	button.text = label
	button.custom_minimum_size = Vector2(104, 25)
	button.pressed.connect(callable)
	parent.add_child(button)
