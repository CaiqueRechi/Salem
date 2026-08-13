extends Resource
class_name PetBehaviourConfig

const STATES := ["idle", "walk", "sit", "sleep", "eat", "play", "stretch", "curious"]

@export var base_state_weights := {
	"idle": 18.0,
	"walk": 16.0,
	"sit": 14.0,
	"sleep": 8.0,
	"eat": 8.0,
	"play": 10.0,
	"stretch": 8.0,
	"curious": 12.0
}

@export var mood_modifiers := {
	"happy": {"play": 16.0, "walk": 8.0, "curious": 6.0},
	"sleepy": {"sleep": 28.0, "sit": 14.0, "stretch": 8.0, "play": -8.0},
	"playful": {"play": 28.0, "walk": 10.0, "curious": 8.0, "sleep": -6.0},
	"curious": {"curious": 25.0, "walk": 8.0, "play": 4.0},
	"hungry": {"eat": 30.0, "walk": 6.0, "sleep": -8.0},
	"grumpy": {"sit": 16.0, "sleep": 12.0, "play": -10.0},
	"neutral": {}
}

@export var state_duration_ranges := {
	"idle": Vector2(2.5, 5.0),
	"walk": Vector2(2.0, 4.0),
	"sit": Vector2(4.0, 7.0),
	"sleep": Vector2(6.0, 10.0),
	"eat": Vector2(3.0, 5.0),
	"play": Vector2(2.0, 4.5),
	"stretch": Vector2(2.0, 3.5),
	"curious": Vector2(3.0, 6.0)
}

@export var cozy_points_per_active_minute := 1.0
@export var stat_tick_seconds := 30.0
@export var state_decision_seconds := 4.0

func get_duration_for_state(state_id: String, rng: RandomNumberGenerator) -> float:
	var range: Vector2 = state_duration_ranges.get(state_id, Vector2(3.0, 5.0))
	return rng.randf_range(range.x, range.y)

func calculate_next_state(
	current_state: String,
	stats: PetStats,
	personality: PersonalityProfile,
	time_period: String,
	rng: RandomNumberGenerator
) -> String:
	var weights := base_state_weights.duplicate(true)
	var mood_weights: Dictionary = mood_modifiers.get(stats.mood, {})
	for state_id in mood_weights.keys():
		weights[state_id] = maxf(0.0, float(weights.get(state_id, 0.0)) + float(mood_weights[state_id]))

	weights["play"] = maxf(0.0, float(weights["play"]) + personality.playfulness * 12.0)
	weights["sleep"] = maxf(0.0, float(weights["sleep"]) + personality.sleepiness * 10.0)
	weights["curious"] = maxf(0.0, float(weights["curious"]) + personality.curiosity * 14.0)
	weights["walk"] = maxf(0.0, float(weights["walk"]) + personality.chaos * 8.0)

	if time_period == "night" or time_period == "late_night":
		weights["sleep"] += 18.0
		weights["curious"] += 5.0

	if current_state != "idle":
		weights[current_state] = maxf(0.0, float(weights.get(current_state, 0.0)) * 0.35)

	return _pick_weighted(weights, rng)

func _pick_weighted(weights: Dictionary, rng: RandomNumberGenerator) -> String:
	var total := 0.0
	for value in weights.values():
		total += maxf(0.0, float(value))

	if total <= 0.0:
		return "idle"

	var roll := rng.randf_range(0.0, total)
	var cursor := 0.0
	for state_id in weights.keys():
		cursor += maxf(0.0, float(weights[state_id]))
		if roll <= cursor:
			return state_id
	return "idle"
