class_name BlockFacing
extends Node
## Turns the guard toward the blow (F6 task 3): while the player blocks without a lock,
## they face the nearest warrior swinging at them within `block_face_range`, using the
## same turn as a lock. The diagnosis (docs/fases/F6-diagnostico-bloqueo.md) found that
## most blows got through a held guard from outside its frontal arc. With a lock it does
## nothing: the lock already faces the target.

@export var tuning: DefenseTuning
@export var player: PlayerController
@export var defense: DefenseComponent
@export var lock_on: LockOnController

## The warrior the guard faces now; null when it does not steer the player.
var _facing: Node3D


func _ready() -> void:
	assert(tuning != null and player != null, "BlockFacing: tuning and player.")
	assert(defense != null and lock_on != null, "BlockFacing: defense and lock-on.")


func _physics_process(_delta: float) -> void:
	tick()


## Public so tests can drive it.
func tick() -> void:
	if lock_on.is_locked():
		# The lock owns the facing; forget ours without undoing it.
		_facing = null
		return
	if not defense.is_blocking():
		_let_go()
		return
	var targets: Array[LockOnTarget] = lock_on.nearby_targets()
	var positions: Array[Vector3] = []
	var threats: Array[bool] = []
	for target: LockOnTarget in targets:
		positions.append(target.global_position)
		threats.append(target.is_threatening())
	var index: int = pick(player.global_position, positions, threats, tuning.block_face_range)
	if index >= 0 and targets[index] != _facing:
		_facing = targets[index]
		player.set_face_target(_facing)


## The warrior the guard faces, if any.
func facing() -> Node3D:
	return _facing


## Index of the nearest threatening position within `reach` of `origin` (ground plane),
## or -1. Pure, for tests.
static func pick(
	origin: Vector3, positions: Array[Vector3], threats: Array[bool], reach: float
) -> int:
	var best: int = -1
	var best_dist: float = reach
	for i: int in positions.size():
		if not threats[i]:
			continue
		var flat := Vector2(positions[i].x - origin.x, positions[i].z - origin.z)
		var dist: float = flat.length()
		if dist <= best_dist:
			best = i
			best_dist = dist
	return best


func _let_go() -> void:
	if _facing != null:
		_facing = null
		player.release_face_target()
