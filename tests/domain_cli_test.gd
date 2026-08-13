extends SceneTree

const PetBehaviourConfig = preload("res://src/pet/pet_behaviour_config.gd")
const PetStats = preload("res://src/pet/pet_stats.gd")
const PersonalityProfile = preload("res://src/pet/personality_profile.gd")
const RandomEvent = preload("res://src/events/random_event.gd")
const TimeService = preload("res://src/core/time_service.gd")
const SaveManagerScript = preload("res://src/core/save_manager.gd")

var _failures := 0

func _initialize() -> void:
	_test_mood_calculation()
	_test_weighted_state_selection()
	_test_random_event_conditions()
	_test_time_periods()
	_test_save_default_merge()
	quit(_failures)

func _test_mood_calculation() -> void:
	var stats = PetStats.new()
	var personality = PersonalityProfile.new()
	stats.hunger = 10.0
	stats.recalculate_mood(personality)
	_expect(stats.mood == "hungry", "Low hunger should set hungry mood.")

func _test_weighted_state_selection() -> void:
	var config = PetBehaviourConfig.new()
	var stats = PetStats.new()
	var personality = PersonalityProfile.new()
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	stats.mood = "sleepy"
	var state: String = config.calculate_next_state("idle", stats, personality, "night", rng)
	_expect(PetBehaviourConfig.STATES.has(state), "FSM should select a known state.")

func _test_random_event_conditions() -> void:
	var event = RandomEvent.new("void", 1.0, 10.0, ["curious"], ["late_night"])
	event.elapsed_since_trigger = 11.0
	_expect(event.can_trigger("curious", "late_night"), "Event should pass matching conditions.")
	_expect(not event.can_trigger("happy", "late_night"), "Event should reject non-matching mood.")

func _test_time_periods() -> void:
	var time_service = TimeService.new()
	_expect(time_service.get_period_name(time_service.get_period_for_hour(3)) == "late_night", "03:00 should be late night.")
	_expect(time_service.get_period_name(time_service.get_period_for_hour(14)) == "afternoon", "14:00 should be afternoon.")

func _test_save_default_merge() -> void:
	var save_manager = SaveManagerScript.new()
	var merged: Dictionary = save_manager._merge_defaults({"a": {"b": 1}, "c": 2}, {"a": {"d": 3}})
	_expect(merged["a"]["b"] == 1 and merged["a"]["d"] == 3 and merged["c"] == 2, "Save merge should keep nested defaults.")

func _expect(condition: bool, message: String) -> void:
	if condition:
		print("[PASS] %s" % message)
	else:
		_failures += 1
		push_error("[FAIL] %s" % message)
