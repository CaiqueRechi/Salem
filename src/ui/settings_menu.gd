extends PanelContainer
class_name SettingsMenu

signal settings_updated(settings)
signal reset_position_requested()
signal reset_save_requested()

var _settings
var _scale_slider: HSlider
var _always_on_top: CheckBox
var _sounds: CheckBox
var _animations: CheckBox
var _pomodoro: CheckBox
var _passthrough: CheckBox

func _ready() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	position = Vector2(16, 16)
	_build()

func bind(settings) -> void:
	_settings = settings
	_refresh()

func _build() -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#1D161F", 0.96)
	style.border_color = Color("#533D64")
	style.set_border_width_all(2)
	style.set_corner_radius_all(6)
	add_theme_stylebox_override("panel", style)

	var box := VBoxContainer.new()
	box.custom_minimum_size = Vector2(220, 0)
	add_child(box)

	var title := Label.new()
	title.text = "Settings"
	title.add_theme_color_override("font_color", Color("#FFECA5"))
	box.add_child(title)

	_always_on_top = _add_check(box, "Always on Top")
	_sounds = _add_check(box, "Sounds")
	_animations = _add_check(box, "Animations")
	_pomodoro = _add_check(box, "Pomodoro")
	_passthrough = _add_check(box, "Mouse Passthrough")

	var scale_label := Label.new()
	scale_label.text = "Pet Scale"
	scale_label.add_theme_color_override("font_color", Color("#FFECA5"))
	box.add_child(scale_label)

	_scale_slider = HSlider.new()
	_scale_slider.min_value = 0.75
	_scale_slider.max_value = 2.0
	_scale_slider.step = 0.05
	_scale_slider.value_changed.connect(_on_scale_changed)
	box.add_child(_scale_slider)

	_add_command(box, "Reset Position", reset_position_requested.emit)
	_add_command(box, "Reset Save", reset_save_requested.emit)
	_add_command(box, "Close", func() -> void: visible = false)

func _add_check(parent: VBoxContainer, label: String) -> CheckBox:
	var check := CheckBox.new()
	check.text = label
	check.add_theme_color_override("font_color", Color("#FFECA5"))
	check.toggled.connect(_on_toggle_changed)
	parent.add_child(check)
	return check

func _add_command(parent: VBoxContainer, label: String, callable: Callable) -> void:
	var button := Button.new()
	button.text = label
	button.pressed.connect(callable)
	parent.add_child(button)

func _refresh() -> void:
	if _settings == null or _scale_slider == null:
		return
	_always_on_top.button_pressed = _settings.always_on_top
	_sounds.button_pressed = _settings.sounds_enabled
	_animations.button_pressed = _settings.animations_enabled
	_pomodoro.button_pressed = _settings.pomodoro_enabled
	_passthrough.button_pressed = _settings.mouse_passthrough_enabled
	_scale_slider.value = _settings.pet_scale

func _on_toggle_changed(_enabled: bool) -> void:
	if _settings == null:
		return
	_settings.always_on_top = _always_on_top.button_pressed
	_settings.sounds_enabled = _sounds.button_pressed
	_settings.animations_enabled = _animations.button_pressed
	_settings.pomodoro_enabled = _pomodoro.button_pressed
	_settings.mouse_passthrough_enabled = _passthrough.button_pressed
	settings_updated.emit(_settings)

func _on_scale_changed(value: float) -> void:
	if _settings == null:
		return
	_settings.pet_scale = value
	settings_updated.emit(_settings)
