extends Node
class_name DeveloperActivityProvider

signal developer_event(event_id: String, payload: Dictionary)

const EVENTS := [
	"commit_created",
	"tests_passed",
	"tests_failed",
	"build_passed",
	"build_failed",
	"coding_session_started",
	"coding_session_finished",
	"break_recommended"
]

func emit_developer_event(event_id: String, payload := {}) -> void:
	if not EVENTS.has(event_id):
		Logger.warn(Logger.Category.INTEGRATION, "Unknown developer event: %s" % event_id)
		return
	developer_event.emit(event_id, payload)
	EventBus.developer_event_received.emit(event_id, payload)
