extends Node
class_name SystemActivityProvider

signal idle_state_changed(is_idle: bool)

var idle_threshold_seconds := 300.0
var _mock_idle := false

func is_user_idle() -> bool:
	return _mock_idle

func set_mock_idle(is_idle: bool) -> void:
	if _mock_idle == is_idle:
		return
	_mock_idle = is_idle
	idle_state_changed.emit(_mock_idle)
