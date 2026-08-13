extends Node
class_name GameManager

const AppSettings = preload("res://src/core/app_settings.gd")
const TimeService = preload("res://src/core/time_service.gd")
const DesktopWindowManager = preload("res://src/platform/desktop_window_manager.gd")
const PetController = preload("res://src/pet/pet_controller.gd")
const PetStats = preload("res://src/pet/pet_stats.gd")
const PersonalityProfile = preload("res://src/pet/personality_profile.gd")
const CozyPoints = preload("res://src/progression/cozy_points.gd")
const UnlockManager = preload("res://src/progression/unlock_manager.gd")
const ObjectManager = preload("res://src/objects/object_manager.gd")
const RandomEventManager = preload("res://src/events/random_event_manager.gd")
const MockDeveloperActivityProvider = preload("res://src/integrations/mock_developer_activity_provider.gd")
const SystemActivityProvider = preload("res://src/integrations/system_activity_provider.gd")
const PomodoroTimer = preload("res://src/integrations/pomodoro_timer.gd")
const AudioService = preload("res://src/audio/audio_service.gd")
const InteractionMenu = preload("res://src/ui/interaction_menu.gd")
const SettingsMenu = preload("res://src/ui/settings_menu.gd")
const DebugPanel = preload("res://src/ui/debug_panel.gd")
const StatusHud = preload("res://src/ui/status_hud.gd")

var settings
var time_service
var window_manager
var pet
var cozy_points
var unlock_manager
var object_manager
var random_event_manager
var developer_provider
var system_activity_provider
var pomodoro
var audio_service

var _interaction_menu
var _settings_menu
var _debug_panel
var _status_hud
var _cozy_timer := Timer.new()
var _save_debounce := Timer.new()

func _ready() -> void:
	settings = AppSettings.new()
	time_service = TimeService.new()
	window_manager = DesktopWindowManager.new()
	pet = PetController.new()
	cozy_points = CozyPoints.new()
	unlock_manager = UnlockManager.new()
	object_manager = ObjectManager.new()
	random_event_manager = RandomEventManager.new()
	developer_provider = MockDeveloperActivityProvider.new()
	system_activity_provider = SystemActivityProvider.new()
	pomodoro = PomodoroTimer.new()
	audio_service = AudioService.new()
	_interaction_menu = InteractionMenu.new()
	_settings_menu = SettingsMenu.new()
	_debug_panel = DebugPanel.new()
	_status_hud = StatusHud.new()

	add_child(time_service)
	add_child(window_manager)
	add_child(cozy_points)
	add_child(unlock_manager)
	add_child(object_manager)
	add_child(random_event_manager)
	add_child(developer_provider)
	add_child(system_activity_provider)
	add_child(pomodoro)
	add_child(audio_service)

	var data := SaveManager.load_game(_default_save_data())
	_apply_save_values(data)

	window_manager.configure(get_window(), settings)
	window_manager.set_position(_vector2i_from_array(data.get("window_position", [120, 120])))

	unlock_manager.setup()
	object_manager.setup(unlock_manager)
	object_manager.object_action_requested.connect(_on_object_action_requested)
	add_child(pet)
	pet.setup(time_service)
	pet.apply_save(data.get("pet", {}))
	pet.scale = Vector2.ONE * settings.pet_scale
	_update_interactive_region()

	random_event_manager.setup(pet.stats, time_service)
	random_event_manager.event_selected.connect(_on_random_event)
	pomodoro.setup(settings)

	_setup_ui()
	_setup_timers()
	_connect_events()
	EventBus.emit_notification("Salem is awake.")

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_now()

func save_now() -> void:
	SaveManager.save_game(_collect_save_data())

func load_now() -> void:
	_apply_runtime_data(SaveManager.load_game(_default_save_data()))

func reset_save() -> void:
	SaveManager.reset_save()
	var default_data := _default_save_data()
	_apply_runtime_data(default_data)
	EventBus.emit_notification("Fresh blanket, fresh save.")

func _setup_ui() -> void:
	add_child(_status_hud)
	add_child(_interaction_menu)
	add_child(_settings_menu)
	add_child(_debug_panel)
	_settings_menu.bind(settings)

	_interaction_menu.action_selected.connect(pet.interact)
	_interaction_menu.settings_requested.connect(func() -> void: _settings_menu.visible = true)
	_settings_menu.settings_updated.connect(_on_settings_updated)
	_settings_menu.reset_position_requested.connect(_reset_position)
	_settings_menu.reset_save_requested.connect(reset_save)

	_debug_panel.mood_requested.connect(pet.set_mood)
	_debug_panel.state_requested.connect(pet.force_state)
	_debug_panel.cozy_points_requested.connect(cozy_points.add_points)
	_debug_panel.random_event_requested.connect(random_event_manager.trigger)
	_debug_panel.developer_event_requested.connect(developer_provider.emit_developer_event)
	_debug_panel.save_requested.connect(save_now)
	_debug_panel.load_requested.connect(load_now)
	_debug_panel.reset_requested.connect(reset_save)
	EventBus.notification_requested.connect(func(_message: String) -> void: audio_service.play_cue("notification"))

func _setup_timers() -> void:
	_cozy_timer.wait_time = 60.0
	_cozy_timer.timeout.connect(func() -> void:
		cozy_points.add_points(int(pet.behaviour_config.cozy_points_per_active_minute))
		_queue_save()
	)
	add_child(_cozy_timer)
	_cozy_timer.start()

	_save_debounce.one_shot = true
	_save_debounce.wait_time = 1.2
	_save_debounce.timeout.connect(save_now)
	add_child(_save_debounce)

func _connect_events() -> void:
	pet.moved.connect(func(_position: Vector2) -> void:
		_update_interactive_region()
		_queue_save()
	)
	pet.stats.stats_changed.connect(func(_stats) -> void: _queue_save())
	EventBus.cozy_points_changed.connect(func(_total: int, _delta: int) -> void: _queue_save())
	EventBus.settings_changed.connect(func(_settings: Dictionary) -> void: _queue_save())

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		_interaction_menu.show_at(get_viewport().get_mouse_position())

func _on_settings_updated(updated_settings) -> void:
	settings = updated_settings
	pet.scale = Vector2.ONE * settings.pet_scale
	window_manager.apply_settings(settings)
	pomodoro.apply_settings(settings)
	audio_service.apply_settings(settings)
	_update_interactive_region()
	EventBus.settings_changed.emit(settings.to_dictionary())

func _on_random_event(event_id: String) -> void:
	match event_id:
		"zoomies":
			pet.force_state("walk")
			var tween := create_tween()
			tween.tween_property(pet, "position:x", 380.0 if pet.position.x < 210.0 else 40.0, 0.65)
			tween.tween_callback(_update_interactive_region)
			cozy_points.add_points(3)
			EventBus.emit_notification("Salem found the zoomies.")
		"stare_into_void":
			pet.force_state("curious")
			cozy_points.add_points(2)
			EventBus.emit_notification("Salem is inspecting nothing in particular.")
		"random_sleep":
			pet.force_state("sleep")
			EventBus.emit_notification("Salem chose a very logical nap spot.")

func _on_object_action_requested(object_id: String, action_id: String) -> void:
	match action_id:
		"enter_box":
			pet.force_state("curious")
			cozy_points.add_points(2)
			audio_service.play_cue("interaction")
			EventBus.emit_notification("Salem is considering the box professionally.")
		"code":
			pet.force_state("sit")
			cozy_points.add_points(4)
			developer_provider.emit_developer_event("coding_session_started", {"source": object_id})
			EventBus.emit_notification("Salem is pair programming.")
		"sleep_bed":
			pet.force_state("sleep")
			pet.stats.rest(10.0, pet.personality)
			cozy_points.add_points(1)
			audio_service.play_cue("sleep")

func _reset_position() -> void:
	pet.position = Vector2(200, 132)
	window_manager.set_position(Vector2i(120, 120))
	_update_interactive_region()
	_queue_save()

func _queue_save() -> void:
	if _save_debounce.is_inside_tree():
		_save_debounce.start()

func _default_save_data() -> Dictionary:
	var default_stats := PetStats.new()
	var default_personality := PersonalityProfile.new()
	var default_settings := AppSettings.new()
	return {
		"window_position": [120, 120],
		"settings": default_settings.to_dictionary(),
		"pet": {
			"position": [200.0, 132.0],
			"stats": default_stats.to_dictionary(),
			"personality": default_personality.to_dictionary()
		},
		"progression": {"total": 0},
		"unlocks": {"unlocked_objects": UnlockManager.DEFAULT_UNLOCKED}
	}

func _apply_save_values(data: Dictionary) -> void:
	settings.apply_dictionary(data.get("settings", {}))
	cozy_points.apply_save(data.get("progression", {}))
	unlock_manager.apply_save(data.get("unlocks", {}))

func _apply_runtime_data(data: Dictionary) -> void:
	_apply_save_values(data)
	if pet.is_inside_tree():
		pet.apply_save(data.get("pet", {}))
		pet.scale = Vector2.ONE * settings.pet_scale
	if object_manager.is_inside_tree():
		object_manager.setup(unlock_manager)
	if window_manager.is_inside_tree():
		window_manager.set_position(_vector2i_from_array(data.get("window_position", [120, 120])))
		window_manager.apply_settings(settings)
	if pomodoro.is_inside_tree():
		pomodoro.apply_settings(settings)
	if audio_service.is_inside_tree():
		audio_service.apply_settings(settings)
	if _settings_menu.is_inside_tree():
		_settings_menu.bind(settings)
	_update_interactive_region()

func _collect_save_data() -> Dictionary:
	return {
		"window_position": [window_manager.get_position().x, window_manager.get_position().y],
		"settings": settings.to_dictionary(),
		"pet": pet.to_dictionary(),
		"progression": cozy_points.to_dictionary(),
		"unlocks": unlock_manager.to_dictionary(),
		"last_session_unix": Time.get_unix_time_from_system()
	}

func _vector2i_from_array(value: Variant) -> Vector2i:
	if typeof(value) == TYPE_ARRAY and value.size() >= 2:
		return Vector2i(int(value[0]), int(value[1]))
	return Vector2i(120, 120)

func _update_interactive_region() -> void:
	if not pet.is_inside_tree() or not window_manager.is_inside_tree():
		return
	var size: Vector2 = Vector2(112.0, 120.0) * float(settings.pet_scale)
	window_manager.set_interactive_region(Rect2(pet.position - size * 0.5, size))
	window_manager.set_mouse_passthrough(settings.mouse_passthrough_enabled)
