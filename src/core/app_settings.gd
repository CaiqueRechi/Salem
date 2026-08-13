extends Resource
class_name AppSettings

@export var always_on_top := true
@export var sounds_enabled := true
@export var animations_enabled := true
@export var pomodoro_enabled := false
@export var work_duration_seconds := 1500
@export var break_duration_seconds := 300
@export_range(0.75, 2.0, 0.05) var pet_scale := 1.0
@export var mouse_passthrough_enabled := false

func to_dictionary() -> Dictionary:
	return {
		"always_on_top": always_on_top,
		"sounds_enabled": sounds_enabled,
		"animations_enabled": animations_enabled,
		"pomodoro_enabled": pomodoro_enabled,
		"work_duration_seconds": work_duration_seconds,
		"break_duration_seconds": break_duration_seconds,
		"pet_scale": pet_scale,
		"mouse_passthrough_enabled": mouse_passthrough_enabled
	}

func apply_dictionary(data: Dictionary) -> void:
	always_on_top = bool(data.get("always_on_top", always_on_top))
	sounds_enabled = bool(data.get("sounds_enabled", sounds_enabled))
	animations_enabled = bool(data.get("animations_enabled", animations_enabled))
	pomodoro_enabled = bool(data.get("pomodoro_enabled", pomodoro_enabled))
	work_duration_seconds = int(data.get("work_duration_seconds", work_duration_seconds))
	break_duration_seconds = int(data.get("break_duration_seconds", break_duration_seconds))
	pet_scale = float(data.get("pet_scale", pet_scale))
	mouse_passthrough_enabled = bool(data.get("mouse_passthrough_enabled", mouse_passthrough_enabled))
