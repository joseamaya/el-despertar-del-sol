class_name SettingsDefaults
extends Resource
## Defaults and limits of the player settings (F4 task 8, GDD §12.4).

## Master volume, linear (0 is silence).
@export_range(0.0, 1.0, 0.05) var volume: float = 0.8
## Camera sensitivity: a factor on the camera tuning (mouse and stick).
@export_range(0.05, 5.0, 0.05) var look_sensitivity: float = 1.0
@export_range(0.05, 5.0, 0.05) var look_sensitivity_min: float = 0.25
@export_range(0.05, 5.0, 0.05) var look_sensitivity_max: float = 3.0
## Share of 1080p the 3D is rendered at, and the choices offered (DECISIONS/0005: 83 %).
@export_range(0.5, 1.0, 0.01) var scale_3d: float = 0.83
@export var scale_3d_options: PackedFloat32Array = PackedFloat32Array([0.75, 0.83, 1.0])
## Their names, translation keys, in the same order.
@export var scale_3d_names: Array[StringName] = [
	&"SETTINGS_SCALE_PERFORMANCE", &"SETTINGS_SCALE_BALANCED", &"SETTINGS_SCALE_QUALITY"
]
