extends Node

signal pet_state_changed(previous_state: String, next_state: String)
signal pet_mood_changed(previous_mood: String, next_mood: String)
signal pet_stats_changed(stats: Dictionary)
signal cozy_points_changed(total: int, delta: int)
signal object_unlocked(object_id: String)
signal developer_event_received(event_id: String, payload: Dictionary)
signal random_event_triggered(event_id: String)
signal settings_changed(settings: Dictionary)
signal save_requested()
signal load_requested()
signal reset_requested()
signal notification_requested(message: String)

func emit_notification(message: String) -> void:
	notification_requested.emit(message)
