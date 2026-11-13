class_name Hitbox
extends Node3D
## Weapon area. While active it tests its shape along the whole path travelled since the
## previous physics frame, so fast swings never skip a body (DECISIONS/0006). Each Hurtbox
## is hit at most once per activation; allies are ignored.

signal hit_landed(hurtbox: Hurtbox, info: HitInfo)

@export var shape: Shape3D
@export var faction: HitRules.Faction = HitRules.Faction.NEUTRAL
## Max distance between tested positions. Smaller than the weapon head.
@export_range(0.01, 1.0, 0.01, "suffix:m") var sweep_step: float = 0.1

var _active: bool = false
var _info: HitInfo
var _previous: Vector3 = Vector3.ZERO
var _already_hit: Array[Hurtbox] = []


func _ready() -> void:
	assert(shape != null, "Hitbox needs a shape.")


func _physics_process(_delta: float) -> void:
	if _active:
		sweep()


func activate(info: HitInfo) -> void:
	_info = info
	_active = true
	_already_hit.clear()
	_previous = global_position


func deactivate() -> void:
	_active = false
	_info = null


func is_active() -> bool:
	return _active


## Tests the path since the last call. Public so tests can drive it.
func sweep() -> void:
	var current: Vector3 = global_position
	var direction: Vector3 = (current - _previous).normalized()
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = shape
	query.collision_mask = HitRules.HURTBOX_LAYER
	query.collide_with_areas = true
	query.collide_with_bodies = false
	var space: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	for point: Vector3 in HitRules.sweep_points(_previous, current, sweep_step):
		if not _active:
			break
		query.transform = Transform3D(global_basis, point)
		for result: Dictionary in space.intersect_shape(query):
			_try_hit(result["collider"] as Hurtbox, point, direction)
	_previous = current


func _try_hit(hurtbox: Hurtbox, point: Vector3, direction: Vector3) -> void:
	if hurtbox == null or _already_hit.has(hurtbox):
		return
	if not HitRules.can_hit(faction, hurtbox.faction):
		return
	_already_hit.append(hurtbox)
	var info: HitInfo = _info.for_target(point, direction)
	hurtbox.receive_hit(info)
	hit_landed.emit(hurtbox, info)
