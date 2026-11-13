class_name LockOnTarget
extends Area3D
## Marks its owner as lockable. Lives on the lock_on physics layer, where the player's
## lock-on sensor finds it. Needs a CollisionShape3D child.

const LAYER: int = 1 << 4

## Height above this node's origin the camera and player aim at.
@export_range(0.0, 3.0, 0.05, "suffix:m") var aim_height: float = 1.2


func _ready() -> void:
	collision_layer = LAYER
	collision_mask = 0
	monitoring = false
	monitorable = true


func get_aim_point() -> Vector3:
	return global_position + Vector3.UP * aim_height
