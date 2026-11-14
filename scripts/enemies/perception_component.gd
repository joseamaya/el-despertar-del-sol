class_name PerceptionComponent
extends Node
## Senses one target (the player) with a view cone plus line of sight, and a hearing
## radius. Keeps the last known position and reports when the target is spotted or lost.

signal target_spotted(target: Node3D)
signal target_lost

const WORLD_MASK: int = 1

@export var data: EnemyData
@export var body: CharacterBody3D
## Injected by the level; never searched for.
@export var target: Node3D

var last_known_position: Vector3 = Vector3.ZERO
var _has_target: bool = false
var _unsensed_time: float = 0.0


func _ready() -> void:
	assert(data != null and body != null, "PerceptionComponent needs data and body.")


func _physics_process(delta: float) -> void:
	tick(delta)


## Updates awareness. Public so tests can drive it.
func tick(delta: float) -> void:
	if target == null or not is_instance_valid(target):
		_lose()
		return
	if can_sense():
		last_known_position = target.global_position
		_unsensed_time = 0.0
		if not _has_target:
			_has_target = true
			target_spotted.emit(target)
		return
	if _has_target:
		_unsensed_time += delta
		if _unsensed_time >= data.lose_target_time:
			_lose()


func has_target() -> bool:
	return _has_target


## Sees it (in cone and in line of sight) or hears it (within radius).
func can_sense() -> bool:
	return can_hear() or can_see()


func can_hear() -> bool:
	return PerceptionRules.heard(body.global_position, target.global_position, data.hearing_radius)


func can_see() -> bool:
	var forward: Vector3 = body.global_basis * Vector3.FORWARD
	if not PerceptionRules.in_view_cone(
		body.global_position,
		forward,
		target.global_position,
		data.view_distance,
		data.view_angle_deg
	):
		return false
	var eye: Vector3 = body.global_position + Vector3.UP * data.eye_height
	var query := PhysicsRayQueryParameters3D.create(
		eye, target.global_position + Vector3.UP * 1.2, WORLD_MASK
	)
	query.exclude = [body.get_rid()]
	var hit: Dictionary = body.get_world_3d().direct_space_state.intersect_ray(query)
	return hit.is_empty() or hit["collider"] == target


func _lose() -> void:
	if _has_target:
		_has_target = false
		_unsensed_time = 0.0
		target_lost.emit()
