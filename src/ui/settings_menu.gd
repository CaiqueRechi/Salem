extends PanelContainer
class_name SettingsMenu

signal settings_updated(settings)
signal reset_position_requested()
signal reset_save_requested()

const PLUM := Color("#533D64")
const CORAL := Color("#DB633A")
const GOLD := Color("#D4A047")
const CREAM := Color("#FFECA5")

var _settings
var _refreshing := false
var _scale_slider: HSlider
var _always_on_top: CheckBox
var _sounds: CheckBox
var _animations: CheckBox
var _pomodoro: CheckBox
var _passthrough: CheckBox

func _ready() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	position = Vector2(25.0, 54.0)
	z_index = 60
	_build()

func bind(settings) -> void:
	_settings = settings
	_refresh()

func open() -> void:
	visible = true
	modulate.a = 0.0
	position.y = 59.0
	var tween := create_tween().set_parallel(true)
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 1.0, 0.16)
	tween.tween_property(self, "position:y", 54.0, 0.20)

func _build() -> void:
	add_theme_stylebox_override("panel", _panel_style())

	var box := VBoxContainer.new()
	box.custom_minimum_size = Vector2(346.0, 0.0)
	box.add_theme_constant_override("separation", 7)
	add_child(box)

	var header := HBoxContainer.new()
	box.add_child(header)
	var title := Label.new()
	title.text = "Make Salem feel at home"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size", 14)
	title.add_theme_color_override("font_color", CREAM)
	header.add_child(title)
	var done := _command_button("Done", func() -> void: visible = false, GOLD)
	done.custom_minimum_size = Vector2(58.0, 25.0)
	header.add_child(done)

	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 14)
	grid.add_theme_constant_override("v_separation", 2)
	box.add_child(grid)
	_always_on_top = _add_check(grid, "Always on top")
	_sounds = _add_check(grid, "Soft sounds")
	_animations = _add_check(grid, "Animations")
	_pomodoro = _add_check(grid, "Pomodoro")
	_passthrough = _add_check(grid, "Click-through mode")

	var scale_row := HBoxContainer.new()
	scale_row.add_theme_constant_override("separation", 10)
	box.add_child(scale_row)
	var scale_label := Label.new()
	scale_label.text = "Salem size"
	scale_label.custom_minimum_size.x = 90.0
	scale_label.add_theme_font_size_override("font_size", 11)
	scale_label.add_theme_color_override("font_color", Color(CREAM, 0.72))
	scale_row.add_child(scale_label)

	_scale_slider = HSlider.new()
	_scale_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_scale_slider.min_value = 0.75
	_scale_slider.max_value = 2.0
	_scale_slider.step = 0.05
	_scale_slider.value_changed.connect(_on_scale_changed)
	scale_row.add_child(_scale_slider)

	var commands := HBoxContainer.new()
	commands.alignment = BoxContainer.ALIGNMENT_END
	commands.add_theme_constant_override("separation", 6)
	box.add_child(commands)
	commands.add_child(_command_button("Reset position", reset_position_requested.emit, PLUM.lightened(0.25)))
	commands.add_child(_command_button("Fresh start", reset_save_requested.emit, CORAL))

func _add_check(parent: Container, label: String) -> CheckBox:
	var check := CheckBox.new()
	check.text = label
	check.custom_minimum_size = Vector2(154.0, 25.0)
	check.focus_mode = Control.FOCUS_NONE
	check.add_theme_font_size_override("font_size", 11)
	check.add_theme_color_override("font_color", Color(CREAM, 0.78))
	check.add_theme_color_override("font_hover_color", CREAM)
	check.toggled.connect(_on_toggle_changed)
	parent.add_child(check)
	return check

func _command_button(label: String, callable: Callable, accent: Color) -> Button:
	var button := Button.new()
	button.text = label
	button.focus_mode = Control.FOCUS_NONE
	button.custom_minimum_size = Vector2(96.0, 27.0)
	button.add_theme_font_size_override("font_size", 10)
	button.add_theme_color_override("font_color", Color(CREAM, 0.84))
	button.add_theme_stylebox_override("normal", _button_style(Color(PLUM, 0.14), Color(PLUM, 0.36)))
	button.add_theme_stylebox_override("hover", _button_style(Color(accent, 0.22), Color(accent, 0.70)))
	button.add_theme_stylebox_override("pressed", _button_style(Color(accent, 0.34), Color(accent, 0.54)))
	button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	button.pressed.connect(callable)
	return button

func _refresh() -> void:
	if _settings == null or _scale_slider == null:
		return
	_refreshing = true
	_always_on_top.button_pressed = _settings.always_on_top
	_sounds.button_pressed = _settings.sounds_enabled
	_animations.button_pressed = _settings.animations_enabled
	_pomodoro.button_pressed = _settings.pomodoro_enabled
	_passthrough.button_pressed = _settings.mouse_passthrough_enabled
	_scale_slider.value = _settings.pet_scale
	_refreshing = false

func _on_toggle_changed(_enabled: bool) -> void:
	if _settings == null or _refreshing:
		return
	_settings.always_on_top = _always_on_top.button_pressed
	_settings.sounds_enabled = _sounds.button_pressed
	_settings.animations_enabled = _animations.button_pressed
	_settings.pomodoro_enabled = _pomodoro.button_pressed
	_settings.mouse_passthrough_enabled = _passthrough.button_pressed
	settings_updated.emit(_settings)

func _on_scale_changed(value: float) -> void:
	if _settings == null or _refreshing:
		return
	_settings.pet_scale = value
	settings_updated.emit(_settings)

func _panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#211927", 0.99)
	style.border_color = Color(PLUM, 0.88)
	style.set_border_width_all(1)
	style.set_corner_radius_all(15)
	style.content_margin_left = 14.0
	style.content_margin_right = 14.0
	style.content_margin_top = 11.0
	style.content_margin_bottom = 11.0
	return style

func _button_style(fill: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(8)
	return style
