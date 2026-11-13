class_name LockOnMarker
extends Node3D
## Temporary world-space marker over the locked target, until the HUD exists (GDD §12.1).
## Connect LockOnController.target_locked / target_switched / target_released to it.

## Height above the target's aim point.
@export_range(0.0, 2.0, 0.05, "suffix:m") var lift: float = 0.7

var _target: LockOnTarget


func _ready() -> void:
	top_level = true
	visible = false


func _process(_delta: float) -> void:
	if _target != null and not is_instance_valid(_target):
		release_target()
	if _target != null:
		global_position = _target.get_aim_point() + Vector3.UP * lift


func set_target(target: LockOnTarget) -> void:
	_target = target
	visible = true


func release_target(_reason: int = 0) -> void:
	_target = null
	visible = false
