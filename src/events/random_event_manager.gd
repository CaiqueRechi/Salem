extends Node
class_name RandomEventManager

signal event_selected(event_id: String)

const RandomEvent = preload("res://src/events/random_event.gd")

var _events: Array[RandomEvent] = []
var _rng := RandomNumberGenerator.new()
var _timer := Timer.new()
var _stats: PetStats
var _time_service: TimeService

func setup(stats: PetStats, time_service: TimeService) -> void:
	_stats = stats
	_time_service = time_service
	_rng.randomize()
	_events = [
		RandomEvent.new("zoomies", 0.32, 80.0, ["playful", "happy", "curious"], []),
		RandomEvent.new("stare_into_void", 0.28, 120.0, ["curious", "neutral"], ["late_night", "night"]),
		RandomEvent.new("random_sleep", 0.16, 180.0, ["sleepy", "neutral"], [])
	]
	_timer.wait_time = 15.0
	_timer.timeout.connect(_roll_events)
	add_child(_timer)
	_timer.start()

func trigger(event_id: String) -> void:
	for event in _events:
		if event.id == event_id:
			event.mark_triggered()
			_emit_event(event.id)
			return

func _process(delta: float) -> void:
	for event in _events:
		event.tick(delta)

func _roll_events() -> void:
	if _stats == null or _time_service == null:
		return
	var period := _time_service.get_period_name()
	for event in _events:
		if event.can_trigger(_stats.mood, period) and _rng.randf() <= event.probability:
			event.mark_triggered()
			_emit_event(event.id)
			return

func _emit_event(event_id: String) -> void:
	event_selected.emit(event_id)
	EventBus.random_event_triggered.emit(event_id)
	Logger.info(Logger.Category.EVENT, "Random event triggered: %s" % event_id)
