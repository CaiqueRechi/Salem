extends Resource
class_name PersonalityProfile

@export_range(0.0, 1.0, 0.05) var playfulness := 0.75
@export_range(0.0, 1.0, 0.05) var sleepiness := 0.65
@export_range(0.0, 1.0, 0.05) var curiosity := 0.85
@export_range(0.0, 1.0, 0.05) var sociability := 0.60
@export_range(0.0, 1.0, 0.05) var chaos := 0.55

func to_dictionary() -> Dictionary:
	return {
		"playfulness": playfulness,
		"sleepiness": sleepiness,
		"curiosity": curiosity,
		"sociability": sociability,
		"chaos": chaos
	}

func apply_dictionary(data: Dictionary) -> void:
	playfulness = float(data.get("playfulness", playfulness))
	sleepiness = float(data.get("sleepiness", sleepiness))
	curiosity = float(data.get("curiosity", curiosity))
	sociability = float(data.get("sociability", sociability))
	chaos = float(data.get("chaos", chaos))
