extends Node2D
class_name SalemView

const SPRITE_ROOT := "res://assets/pets/salem/sprites/salem_sprite_collection_v1/salem_sprite_collection_v1"
const ANIMATION_FOLDERS := {
	"idle": "idle",
	"walk": "walk",
	"sit": "sit",
	"sleep": "sleep",
	"eat": "eat",
	"play": "play",
	"stretch": "stretch",
	"curious": "curious",
	"judge": "judge"
}
const ANIMATION_SPEEDS := {
	"idle": 3.0,
	"walk": 8.0,
	"sit": 4.0,
	"sleep": 2.0,
	"eat": 7.0,
	"play": 8.0,
	"stretch": 6.0,
	"curious": 4.0,
	"judge": 7.0
}

var state_id := "idle":
	set(value):
		state_id = value
		_play_animation()
		queue_redraw()

var mood := "neutral":
	set(value):
		mood = value
		queue_redraw()

var _blink_timer := 0.0
var _eyes_closed := false
var _sprite := AnimatedSprite2D.new()
var _uses_sprite_frames := false
var _motion_time := 0.0

func _ready() -> void:
	_sprite.centered = true
	_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_sprite.scale = Vector2.ONE * 1.28
	add_child(_sprite)
	_uses_sprite_frames = _load_sprite_frames()
	_sprite.visible = _uses_sprite_frames
	_play_animation()

func _process(delta: float) -> void:
	_motion_time += delta
	var bob_speed := 1.2
	var bob_amount := 1.0
	if state_id == "walk" or state_id == "play":
		bob_speed = 5.5
		bob_amount = 2.0
	elif state_id == "sleep":
		bob_speed = 0.65
		bob_amount = 0.45
	_sprite.position.y = sin(_motion_time * bob_speed) * bob_amount
	queue_redraw()
	if _uses_sprite_frames:
		return
	if state_id == "sleep":
		return
	_blink_timer -= delta
	if _blink_timer <= 0.0:
		_eyes_closed = not _eyes_closed
		_blink_timer = 0.12 if _eyes_closed else randf_range(2.0, 5.0)
		queue_redraw()

func set_animations_enabled(enabled: bool) -> void:
	set_process(enabled)
	_sprite.speed_scale = 1.0 if enabled else 0.0
	if not enabled:
		_sprite.position = Vector2.ZERO
		queue_redraw()

func _draw() -> void:
	_draw_soft_shadow()
	if _uses_sprite_frames:
		return
	var body_color := Color("#533D64")
	var accent := Color("#DB633A")
	var eye := Color("#FFECA5")
	var shadow := Color(0.05, 0.04, 0.06, 0.35)
	var font := ThemeDB.get_fallback_font()

	draw_circle(Vector2(0, 27), 28, shadow)
	draw_colored_polygon(PackedVector2Array([
		Vector2(-34, -5), Vector2(-25, -40), Vector2(-8, -20),
		Vector2(8, -20), Vector2(25, -40), Vector2(34, -5),
		Vector2(30, 24), Vector2(0, 34), Vector2(-30, 24)
	]), body_color)
	draw_circle(Vector2(-20, 6), 18, body_color.lightened(0.08))
	draw_circle(Vector2(20, 6), 18, body_color.lightened(0.08))
	draw_circle(Vector2(0, 7), 24, body_color.lightened(0.03))

	if state_id == "sleep":
		draw_line(Vector2(-15, 2), Vector2(-6, 2), eye, 2.0)
		draw_line(Vector2(6, 2), Vector2(15, 2), eye, 2.0)
		draw_string(font, Vector2(31, -23), "z", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, eye)
	elif _eyes_closed:
		draw_line(Vector2(-14, 0), Vector2(-6, 0), eye, 2.0)
		draw_line(Vector2(6, 0), Vector2(14, 0), eye, 2.0)
	else:
		draw_circle(Vector2(-11, 0), 3.5, eye)
		draw_circle(Vector2(11, 0), 3.5, eye)

	draw_circle(Vector2(0, 8), 2.5, accent)
	var mouth_y := 15.0
	if mood == "grumpy":
		draw_arc(Vector2(0, 21), 7.0, PI, TAU, 12, accent, 2.0)
	elif mood == "happy" or mood == "playful":
		draw_arc(Vector2(0, mouth_y), 7.0, 0.0, PI, 12, accent, 2.0)
	else:
		draw_line(Vector2(-4, mouth_y), Vector2(4, mouth_y), accent, 2.0)

	if state_id == "eat":
		draw_circle(Vector2(32, 18), 7, Color("#D4A047"))
	elif state_id == "curious":
		draw_string(font, Vector2(27, -22), "?", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, eye)
	elif state_id == "play":
		draw_circle(Vector2(34, 15), 5, Color("#FFECA5"))
	elif state_id == "judge":
		draw_line(Vector2(24, 12), Vector2(38, 8), Color("#FFECA5"), 2.0)
		draw_string(font, Vector2(26, -24), "...", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, eye)

func _load_sprite_frames() -> bool:
	var frames := SpriteFrames.new()
	var loaded_any := false
	for animation_name in ANIMATION_FOLDERS.keys():
		var folder_path := "%s/%s" % [SPRITE_ROOT, ANIMATION_FOLDERS[animation_name]]
		var files := DirAccess.get_files_at(folder_path)
		var animation_loaded := false
		files.sort()
		frames.add_animation(animation_name)
		frames.set_animation_loop(animation_name, true)
		frames.set_animation_speed(animation_name, float(ANIMATION_SPEEDS.get(animation_name, 6.0)))
		for file_name in files:
			if not file_name.to_lower().ends_with(".png"):
				continue
			if file_name.to_lower().ends_with("_sheet.png"):
				continue
			var texture := _load_texture("%s/%s" % [folder_path, file_name])
			if texture == null:
				continue
			frames.add_frame(animation_name, texture)
			animation_loaded = true
			loaded_any = true
		if not animation_loaded:
			frames.remove_animation(animation_name)

	if loaded_any:
		_sprite.sprite_frames = frames
	return loaded_any

func _draw_soft_shadow() -> void:
	var points := PackedVector2Array()
	for index in range(24):
		var angle := TAU * float(index) / 24.0
		points.append(Vector2(cos(angle) * 30.0, 30.0 + sin(angle) * 7.0))
	draw_colored_polygon(points, Color(0.03, 0.02, 0.04, 0.20))

func _load_texture(resource_path: String) -> Texture2D:
	var image := Image.new()
	var error := image.load(ProjectSettings.globalize_path(resource_path))
	if error != OK:
		return null
	return ImageTexture.create_from_image(image)

func _play_animation() -> void:
	if not _uses_sprite_frames or _sprite.sprite_frames == null:
		return
	var animation_name := state_id
	if not _sprite.sprite_frames.has_animation(animation_name):
		animation_name = "idle"
	if _sprite.animation != animation_name:
		_sprite.play(animation_name)
