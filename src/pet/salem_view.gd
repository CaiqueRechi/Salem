extends Node2D
class_name SalemView

var state_id := "idle":
	set(value):
		state_id = value
		queue_redraw()

var mood := "neutral":
	set(value):
		mood = value
		queue_redraw()

var _blink_timer := 0.0
var _eyes_closed := false

func _process(delta: float) -> void:
	if state_id == "sleep":
		return
	_blink_timer -= delta
	if _blink_timer <= 0.0:
		_eyes_closed = not _eyes_closed
		_blink_timer = 0.12 if _eyes_closed else randf_range(2.0, 5.0)
		queue_redraw()

func _draw() -> void:
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
