extends Resource
class_name PetStats

signal changed(stats: PetStats)
signal mood_changed(previous_mood: String, next_mood: String)

const MIN_VALUE := 0.0
const MAX_VALUE := 100.0

@export_range(0.0, 100.0, 0.5) var energy := 80.0
@export_range(0.0, 100.0, 0.5) var hunger := 70.0
@export_range(0.0, 100.0, 0.5) var affection := 45.0
@export var mood := "neutral"

func tick(minutes: float, personality: PersonalityProfile) -> void:
	var hunger_decay := 0.22 * minutes
	var energy_decay := 0.12 * minutes
	var affection_decay := 0.04 * minutes

	hunger = clampf(hunger - hunger_decay, MIN_VALUE, MAX_VALUE)
	energy = clampf(energy - energy_decay, MIN_VALUE, MAX_VALUE)
	affection = clampf(affection - affection_decay, MIN_VALUE, MAX_VALUE)
	_recalculate_mood(personality)
	changed.emit(self)

func feed(amount := 22.0, personality: PersonalityProfile = null) -> void:
	hunger = clampf(hunger + amount, MIN_VALUE, MAX_VALUE)
	if personality != null:
		_recalculate_mood(personality)
	changed.emit(self)

func pet(amount := 10.0, personality: PersonalityProfile = null) -> void:
	affection = clampf(affection + amount, MIN_VALUE, MAX_VALUE)
	if personality != null:
		_recalculate_mood(personality)
	changed.emit(self)

func play(personality: PersonalityProfile = null) -> void:
	affection = clampf(affection + 8.0, MIN_VALUE, MAX_VALUE)
	energy = clampf(energy - 8.0, MIN_VALUE, MAX_VALUE)
	if personality != null:
		_recalculate_mood(personality)
	changed.emit(self)

func rest(amount := 12.0, personality: PersonalityProfile = null) -> void:
	energy = clampf(energy + amount, MIN_VALUE, MAX_VALUE)
	if personality != null:
		_recalculate_mood(personality)
	changed.emit(self)

func to_dictionary() -> Dictionary:
	return {
		"energy": energy,
		"hunger": hunger,
		"affection": affection,
		"mood": mood
	}

func apply_dictionary(data: Dictionary) -> void:
	energy = clampf(float(data.get("energy", energy)), MIN_VALUE, MAX_VALUE)
	hunger = clampf(float(data.get("hunger", hunger)), MIN_VALUE, MAX_VALUE)
	affection = clampf(float(data.get("affection", affection)), MIN_VALUE, MAX_VALUE)
	mood = str(data.get("mood", mood))
	changed.emit(self)

func recalculate_mood(personality: PersonalityProfile) -> void:
	_recalculate_mood(personality)
	changed.emit(self)

func _recalculate_mood(personality: PersonalityProfile) -> void:
	var previous := mood
	if hunger < 26.0:
		mood = "hungry"
	elif energy < 22.0 or personality.sleepiness > 0.8 and energy < 42.0:
		mood = "sleepy"
	elif affection < 20.0:
		mood = "grumpy"
	elif personality.curiosity > 0.75 and hunger > 45.0:
		mood = "curious"
	elif personality.playfulness > 0.68 and energy > 45.0:
		mood = "playful"
	elif affection > 70.0:
		mood = "happy"
	else:
		mood = "neutral"

	if previous != mood:
		mood_changed.emit(previous, mood)
