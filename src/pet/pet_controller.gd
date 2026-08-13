extends Node2D
class_name PetController

signal moved(position: Vector2)

const SalemView = preload("res://src/pet/salem_view.gd")
const PetStateMachine = preload("res://src/pet/pet_state_machine.gd")
const PetStats = preload("res://src/pet/pet_stats.gd")
const PersonalityProfile = preload("res://src/pet/personality_profile.gd")
const PetBehaviourConfig = preload("res://src/pet/pet_behaviour_config.gd")

var stats := PetStats.new()
var personality := PersonalityProfile.new()
var behaviour_config := PetBehaviourConfig.new()
var state_machine := PetStateMachine.new()

var _view := SalemView.new()
var _interaction_area := Area2D.new()
var _dragging := false
var _drag_offset := Vector2.ZERO
var _stat_timer := Timer.new()

func setup(time_service: Node) -> void:
	name = "Salem"
	add_child(_view)
	add_child(state_machine)
	_setup_interaction_area()
	_setup_stat_timer()

	state_machine.setup(behaviour_config, stats, personality, time_service)
	state_machine.state_changed.connect(_on_state_changed)
	stats.stats_changed.connect(_on_stats_changed)
	stats.mood_changed.connect(_on_mood_changed)
	EventBus.developer_event_received.connect(_on_developer_event)

func apply_save(data: Dictionary) -> void:
	position = _vector_from_array(data.get("position", [180.0, 120.0]))
	stats.apply_dictionary(data.get("stats", {}))
	personality.apply_dictionary(data.get("personality", {}))

func to_dictionary() -> Dictionary:
	return {
		"position": [position.x, position.y],
		"stats": stats.to_dictionary(),
		"personality": personality.to_dictionary(),
		"state": state_machine.current_state
	}

func interact(action_id: String) -> void:
	match action_id:
		"pet":
			stats.pet(10.0, personality)
			EventBus.emit_notification("Salem purrs quietly.")
		"feed":
			stats.feed(22.0, personality)
			state_machine.force_state("eat")
		"play":
			stats.play(personality)
			state_machine.force_state("play")
		"pickup":
			EventBus.emit_notification("Drag Salem anywhere cozy.")

func force_state(state_id: String) -> void:
	state_machine.force_state(state_id)

func set_mood(mood: String) -> void:
	var previous := stats.mood
	stats.mood = mood
	stats.mood_changed.emit(previous, mood)
	_on_stats_changed(stats)

func _setup_interaction_area() -> void:
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(86, 92)
	collision.shape = shape
	_interaction_area.input_pickable = true
	_interaction_area.add_child(collision)
	_interaction_area.input_event.connect(_on_input_event)
	add_child(_interaction_area)

func _setup_stat_timer() -> void:
	_stat_timer.wait_time = behaviour_config.stat_tick_seconds
	_stat_timer.timeout.connect(_on_stat_tick)
	add_child(_stat_timer)
	_stat_timer.start()

func _on_stat_tick() -> void:
	stats.tick(behaviour_config.stat_tick_seconds / 60.0, personality)

func _on_state_changed(_previous_state: String, next_state: String) -> void:
	_view.state_id = next_state
	if next_state == "walk":
		var target_x := clampf(position.x + randf_range(-80.0, 80.0), 60.0, 360.0)
		var tween := create_tween()
		tween.tween_property(self, "position:x", target_x, 2.2).set_trans(Tween.TRANS_SINE)
	elif next_state == "sleep":
		stats.rest(4.0, personality)

func _on_stats_changed(updated_stats) -> void:
	_view.mood = updated_stats.mood
	EventBus.pet_stats_changed.emit(updated_stats.to_dictionary())

func _on_mood_changed(previous_mood: String, next_mood: String) -> void:
	EventBus.pet_mood_changed.emit(previous_mood, next_mood)

func _on_developer_event(event_id: String, _payload: Dictionary) -> void:
	match event_id:
		"commit_created", "tests_passed":
			stats.pet(4.0, personality)
			force_state("play")
		"tests_failed":
			set_mood("grumpy")
			force_state("sit")
		"break_recommended":
			set_mood("sleepy")
			force_state("stretch")

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_dragging = event.pressed
		_drag_offset = get_global_mouse_position() - global_position
		if not event.pressed:
			moved.emit(position)
	elif event is InputEventMouseMotion and _dragging:
		position = get_global_mouse_position() - _drag_offset
		moved.emit(position)

func _vector_from_array(value: Variant) -> Vector2:
	if typeof(value) == TYPE_ARRAY and value.size() >= 2:
		return Vector2(float(value[0]), float(value[1]))
	return Vector2(180.0, 120.0)
