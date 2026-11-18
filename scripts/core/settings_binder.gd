class_name SettingsBinder
extends Node
## Hands the player's settings to the level's nodes that use them (F4 task 8): today the
## camera's sensitivity factor. Volume and 3D scale are applied by the Settings autoload.

@export var camera_rig: CameraController

var _settings: GameSettings


func _ready() -> void:
	assert(camera_rig != null, "SettingsBinder: camera rig.")
	_settings = get_node_or_null(^"/root/Settings") as GameSettings
	if _settings == null:
		return
	_settings.changed.connect(_apply)
	_apply()


func _apply() -> void:
	camera_rig.look_scale = _settings.look_sensitivity
