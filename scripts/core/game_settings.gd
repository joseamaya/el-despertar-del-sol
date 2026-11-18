class_name GameSettings
extends Node
## The player's settings (F4 task 8, GDD §12.4), autoloaded as `Settings`: master volume,
## camera sensitivity and 3D scale. Loads them on start, applies volume and 3D scale
## itself, saves on every change and tells who else needs them (the camera's factor is
## set by SettingsBinder in each level).

signal changed

const DEFAULTS_PATH: String = "res://resources/settings/settings_defaults.tres"
const SECTION: String = "settings"

## Where they are kept. Tests point it elsewhere before adding the node.
var path: String = "user://settings.cfg"
var defaults: SettingsDefaults
var volume: float = 0.8
var look_sensitivity: float = 1.0
var scale_3d: float = 0.83


func _ready() -> void:
	if defaults == null:
		defaults = load(DEFAULTS_PATH) as SettingsDefaults
	load_settings()
	apply()


func set_volume(value: float) -> void:
	volume = clampf(value, 0.0, 1.0)
	_changed()


func set_look_sensitivity(value: float) -> void:
	look_sensitivity = clampf(value, defaults.look_sensitivity_min, defaults.look_sensitivity_max)
	_changed()


## Snaps to the nearest of the offered scales.
func set_scale_3d(value: float) -> void:
	scale_3d = defaults.scale_3d_options[nearest_scale_index(value)]
	_changed()


func nearest_scale_index(value: float) -> int:
	var best: int = 0
	var options: PackedFloat32Array = defaults.scale_3d_options
	for i: int in options.size():
		if absf(options[i] - value) < absf(options[best] - value):
			best = i
	return best


func reset_to_defaults() -> void:
	volume = defaults.volume
	look_sensitivity = defaults.look_sensitivity
	scale_3d = defaults.scale_3d
	_changed()


## Volume on the Master bus and the 3D scale of the main window.
func apply() -> void:
	var master: int = AudioServer.get_bus_index(&"Master")
	AudioServer.set_bus_mute(master, volume <= 0.0)
	AudioServer.set_bus_volume_db(master, linear_to_db(maxf(volume, 0.0001)))
	get_tree().root.scaling_3d_scale = scale_3d


func load_settings() -> void:
	volume = defaults.volume
	look_sensitivity = defaults.look_sensitivity
	scale_3d = defaults.scale_3d
	var file := ConfigFile.new()
	if file.load(path) != OK:
		return
	volume = clampf(float(file.get_value(SECTION, "volume", volume)), 0.0, 1.0)
	look_sensitivity = clampf(
		float(file.get_value(SECTION, "look_sensitivity", look_sensitivity)),
		defaults.look_sensitivity_min,
		defaults.look_sensitivity_max
	)
	var scale: float = float(file.get_value(SECTION, "scale_3d", scale_3d))
	scale_3d = defaults.scale_3d_options[nearest_scale_index(scale)]


func save_settings() -> void:
	var file := ConfigFile.new()
	file.set_value(SECTION, "volume", volume)
	file.set_value(SECTION, "look_sensitivity", look_sensitivity)
	file.set_value(SECTION, "scale_3d", scale_3d)
	file.save(path)


func _changed() -> void:
	apply()
	save_settings()
	changed.emit()
