class_name PauseMenu
extends CanvasLayer
## Pause menu (F4 task 8, GDD §14.2): Esc or Start pauses the game; continue, settings
## (volume, camera sensitivity, 3D scale), start the slice again or quit. It does not open
## over another pause (the codex) nor on the defeat and end screens, where Start retries.
## Builds its own UI; navigable with mouse, keys and pad.

const ACTION_PAUSE: StringName = &"pause"
const ACTION_BACK: StringName = &"ui_cancel"

## Optional: on its defeat screen Start retries instead.
@export var arena: ArenaController
## Optional: once it is over Start plays again instead.
@export var slice: SliceDirector

var _open: bool = false
var _mouse_before: Input.MouseMode = Input.MOUSE_MODE_VISIBLE
var _settings: GameSettings
var _root: Control
var _main: VBoxContainer
var _options: VBoxContainer
var _resume: Button
var _volume: HSlider
var _sensitivity: HSlider
var _sensitivity_value: Label
var _scale: OptionButton


func _ready() -> void:
	layer = 25
	process_mode = Node.PROCESS_MODE_ALWAYS
	_settings = get_node_or_null(^"/root/Settings") as GameSettings
	_root = PauseMenuBuilder.build(self)
	_main = _root.find_child("Main", true, false) as VBoxContainer
	_options = _root.find_child("Options", true, false) as VBoxContainer
	_resume = _main.get_child(1) as Button
	_volume = _options.find_child("Volume", true, false) as HSlider
	_sensitivity = _options.find_child("Sensitivity", true, false) as HSlider
	_sensitivity_value = _options.find_child("SensitivityValue", true, false) as Label
	_scale = _options.find_child("Scale", true, false) as OptionButton
	_connect()
	_root.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(ACTION_PAUSE):
		if _open:
			close()
			get_viewport().set_input_as_handled()
		elif can_open():
			open()
			get_viewport().set_input_as_handled()
	elif _open and event.is_action_pressed(ACTION_BACK):
		if _options.visible:
			show_main()
		else:
			close()
		get_viewport().set_input_as_handled()


## Not over another pause, nor where Start means retry (defeat, the end).
func can_open() -> bool:
	if _open or get_tree().paused:
		return false
	if arena != null and arena.state == ArenaController.EncounterState.DEFEATED:
		return false
	return slice == null or not slice.is_finished()


func open() -> void:
	if not can_open():
		return
	_open = true
	get_tree().paused = true
	_mouse_before = Input.mouse_mode
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_root.visible = true
	show_main()


func close() -> void:
	if not _open:
		return
	_open = false
	_root.visible = false
	get_tree().paused = false
	Input.mouse_mode = _mouse_before


func is_open() -> bool:
	return _open


func show_main() -> void:
	_options.visible = false
	_main.visible = true
	_resume.grab_focus()


func show_options() -> void:
	_main.visible = false
	_options.visible = true
	_refresh_options()
	_volume.grab_focus()


func is_showing_options() -> bool:
	return _open and _options.visible


func _connect() -> void:
	_resume.pressed.connect(close)
	(_main.get_child(2) as Button).pressed.connect(show_options)
	(_main.get_child(3) as Button).pressed.connect(_restart)
	(_main.get_child(4) as Button).pressed.connect(_quit)
	(_options.find_child("Back", true, false) as Button).pressed.connect(show_main)
	_volume.value_changed.connect(_on_volume)
	_sensitivity.value_changed.connect(_on_sensitivity)
	_scale.item_selected.connect(_on_scale)


func _refresh_options() -> void:
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


func _restart() -> void:
	close()
	get_tree().reload_current_scene()


func _quit() -> void:
	get_tree().quit()
