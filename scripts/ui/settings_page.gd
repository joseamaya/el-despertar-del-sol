class_name SettingsPage
extends VBoxContainer
## The settings page shared by the pause menu and the title menu (F8 task 2): volume,
## camera sensitivity and 3D scale, applied to the Settings service as they change. Builds
## its own controls; every text goes through tr().

signal back_pressed

const TEXT := Color(0.96, 0.93, 0.88)
const TITLE := Color(0.95, 0.75, 0.35)

var _settings: GameSettings
var _volume: HSlider
var _sensitivity: HSlider
var _sensitivity_value: Label
var _scale: OptionButton


func _init() -> void:
	name = "Options"
	add_theme_constant_override(&"separation", 14)
	add_child(MenuParts.label(&"PAUSE_SETTINGS", 34, TITLE))
	add_child(MenuParts.label(&"SETTINGS_VOLUME", 22, TEXT))
	_volume = _slider("Volume", 0.0, 1.0, 0.05)
	add_child(_volume)
	var row := HBoxContainer.new()
	row.add_child(MenuParts.label(&"SETTINGS_SENSITIVITY", 22, TEXT))
	_sensitivity_value = MenuParts.label(&"", 22, TITLE)
	_sensitivity_value.name = "SensitivityValue"
	_sensitivity_value.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_sensitivity_value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	row.add_child(_sensitivity_value)
	add_child(row)
	_sensitivity = _slider("Sensitivity", 0.25, 3.0, 0.05)
	add_child(_sensitivity)
	add_child(MenuParts.label(&"SETTINGS_SCALE_3D", 22, TEXT))
	_scale = OptionButton.new()
	_scale.name = "Scale"
	_scale.add_theme_font_size_override(&"font_size", 22)
	add_child(_scale)
	var back := MenuParts.button(&"SETTINGS_BACK")
	back.name = "Back"
	add_child(back)
	back.pressed.connect(back_pressed.emit)
	_volume.value_changed.connect(_on_volume)
	_sensitivity.value_changed.connect(_on_sensitivity)
	_scale.item_selected.connect(_on_scale)


func _ready() -> void:
	_settings = get_node_or_null(^"/root/Settings") as GameSettings


## Shows the current settings in the controls.
func refresh() -> void:
	if _settings == null:
		return
	var d: SettingsDefaults = _settings.defaults
	_sensitivity.min_value = d.look_sensitivity_min
	_sensitivity.max_value = d.look_sensitivity_max
	_volume.set_value_no_signal(_settings.volume)
	_sensitivity.set_value_no_signal(_settings.look_sensitivity)
	_sensitivity_value.text = "%.2f×" % _settings.look_sensitivity
	_scale.clear()
	for i: int in d.scale_3d_options.size():
		_scale.add_item(
			"%s (%d %%)" % [tr(d.scale_3d_names[i]), roundi(d.scale_3d_options[i] * 100.0)]
		)
	_scale.select(_settings.nearest_scale_index(_settings.scale_3d))


## Puts the keyboard and pad focus on the first control.
func focus() -> void:
	_volume.grab_focus()


func _slider(node_name: String, low: float, high: float, step: float) -> HSlider:
	var slider := HSlider.new()
	slider.name = node_name
	slider.min_value = low
	slider.max_value = high
	slider.step = step
	slider.custom_minimum_size = Vector2(0.0, 32.0)
	return slider


func _on_volume(value: float) -> void:
	if _settings != null:
		_settings.set_volume(value)


func _on_sensitivity(value: float) -> void:
	if _settings != null:
		_settings.set_look_sensitivity(value)
		_sensitivity_value.text = "%.2f×" % _settings.look_sensitivity


func _on_scale(index: int) -> void:
	if _settings != null:
		_settings.set_scale_3d(_settings.defaults.scale_3d_options[index])
