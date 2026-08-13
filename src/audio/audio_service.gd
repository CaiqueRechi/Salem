extends Node
class_name AudioService

const KNOWN_CUES := [
	"meow",
	"purr",
	"sleep",
	"interaction",
	"notification"
]

var sounds_enabled := true
var _player := AudioStreamPlayer.new()

func _ready() -> void:
	add_child(_player)

func apply_settings(settings) -> void:
	sounds_enabled = settings.sounds_enabled

func play_cue(cue_id: String) -> void:
	if not sounds_enabled:
		return
	if not KNOWN_CUES.has(cue_id):
		AppLog.warn(AppLog.Category.UI, "Unknown audio cue: %s" % cue_id)
		return
	# Placeholder: final royalty-free sounds can be assigned here without touching callers.
	AppLog.info(AppLog.Category.UI, "Audio cue requested: %s" % cue_id)
