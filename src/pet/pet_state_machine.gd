extends Node
class_name PetStateMachine

const PetBehaviourConfig = preload("res://src/pet/pet_behaviour_config.gd")

signal state_changed(previous_state: String, next_state: String)

var current_state := "idle"
var _config
var _stats
var _personality
var _rng := RandomNumberGenerator.new()
var _time_service: Node
var _state_timer: Timer

func setup(config, stats, personality, time_service: Node) -> void:
	_config = config
	_stats = stats
	_personality = personality
	_time_service = time_service
	_rng.randomize()
	_state_timer = Timer.new()
	_state_timer.one_shot = true
	_state_timer.timeout.connect(_choose_next_state)
	add_child(_state_timer)
	_restart_timer()

func force_state(state_id: String) -> void:
	if not PetBehaviourConfig.STATES.has(state_id):
		return
	_set_state(state_id)
	_restart_timer()

func _choose_next_state() -> void:
	if _config == null:
		return
	var period_name := "afternoon"
	if _time_service != null and _time_service.has_method("get_period_name"):
		period_name = _time_service.get_period_name()
	var next_state: String = _config.calculate_next_state(current_state, _stats, _personality, period_name, _rng)
	_set_state(next_state)
	_restart_timer()

func _set_state(next_state: String) -> void:
	if current_state == next_state:
		return
	var previous := current_state
	current_state = next_state
	state_changed.emit(previous, next_state)
	EventBus.pet_state_changed.emit(previous, next_state)
	AppLog.info(AppLog.Category.STATE, "%s -> %s" % [previous, next_state])

func _restart_timer() -> void:
	if _state_timer == null or _config == null:
		return
	_state_timer.start(_config.get_duration_for_state(current_state, _rng))
