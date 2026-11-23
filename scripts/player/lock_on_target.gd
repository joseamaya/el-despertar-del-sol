class_name LockOnTarget
extends Area3D
## Marks its owner as lockable. Lives on the lock_on physics layer, where the player's
## lock-on sensor finds it. Needs a CollisionShape3D child.

const LAYER: int = 1 << 4

## Height above this node's origin the camera and player aim at.
@export_range(0.0, 3.0, 0.05, "suffix:m") var aim_height: float = 1.2
## Optional: shown by the HUD for the locked target (GDD §12.1).
@export var health: HealthComponent
@export var posture: PostureComponent
## Optional: lets the player's guard turn toward a blow on its way (F6 task 3).
@export var combat: EnemyCombat


func _ready() -> void:
	collision_layer = LAYER
	collision_mask = 0
	monitoring = false
	monitorable = true


func get_aim_point() -> Vector3:
	return global_position + Vector3.UP * aim_height


## Whether its owner is swinging a blow that has not landed yet (windup or active).
func is_threatening() -> bool:
	if combat == null or not combat.is_attacking():
		return false
	return combat.get_phase() in [AttackRules.Phase.WINDUP, AttackRules.Phase.ACTIVE]
