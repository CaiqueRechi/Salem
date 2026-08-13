extends Resource
class_name RandomEvent

var id := ""
var probability := 0.1
var cooldown_seconds := 60.0
var elapsed_since_trigger := 999999.0
var allowed_moods: Array[String] = []
var allowed_periods: Array[String] = []

func _init(
	event_id := "",
	event_probability := 0.1,
	event_cooldown := 60.0,
	moods := [],
	periods := []
) -> void:
	id = event_id
	probability = event_probability
	cooldown_seconds = event_cooldown
	allowed_moods.assign(moods)
	allowed_periods.assign(periods)

func tick(delta: float) -> void:
	elapsed_since_trigger += delta

func can_trigger(mood: String, period: String) -> bool:
	if elapsed_since_trigger < cooldown_seconds:
		return false
	if not allowed_moods.is_empty() and not allowed_moods.has(mood):
		return false
	if not allowed_periods.is_empty() and not allowed_periods.has(period):
		return false
	return true

func mark_triggered() -> void:
	elapsed_since_trigger = 0.0
