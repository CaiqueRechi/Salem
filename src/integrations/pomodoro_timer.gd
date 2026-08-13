extends Node
class_name PomodoroTimer

signal phase_changed(phase: String)

var settings: AppSettings
var _timer := Timer.new()
var _phase := "work"

func setup(app_settings: AppSettings) -> void:
	settings = app_settings
	_timer.one_shot = true
	_timer.timeout.connect(_on_timeout)
	add_child(_timer)
	_apply_settings()

func apply_settings(app_settings: AppSettings) -> void:
	settings = app_settings
	_apply_settings()

func start() -> void:
	if settings == null or not settings.pomodoro_enabled:
		return
	_phase = "work"
	_timer.start(settings.work_duration_seconds)
	phase_changed.emit(_phase)

func stop() -> void:
	_timer.stop()

func _apply_settings() -> void:
	if settings == null:
		return
	if settings.pomodoro_enabled and _timer.is_stopped():
		start()
	elif not settings.pomodoro_enabled:
		stop()

func _on_timeout() -> void:
	if _phase == "work":
		_phase = "break"
		EventBus.developer_event_received.emit("break_recommended", {"source": "pomodoro"})
		_timer.start(settings.break_duration_seconds)
	else:
		_phase = "work"
		_timer.start(settings.work_duration_seconds)
	phase_changed.emit(_phase)
