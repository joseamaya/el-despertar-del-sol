class_name LockOnController
extends Node3D
## Acquires, switches and releases a lock-on target (GDD §6.2). Candidates come from a
## sensor Area3D on the lock_on layer; listeners (camera, player) connect to the signals.

signal target_locked(target: LockOnTarget)
signal target_switched(target: LockOnTarget)
signal target_released(reason: ReleaseReason)

enum ReleaseReason { BUTTON, OUT_OF_RANGE, NO_LINE_OF_SIGHT, TARGET_LOST }

const ACTION_LOCK: StringName = &"lock_on"
const ACTION_SWITCH_LEFT: StringName = &"lock_switch_left"
const ACTION_SWITCH_RIGHT: StringName = &"lock_switch_right"
const ACTION_LOOK_LEFT: StringName = &"look_left"
const ACTION_LOOK_RIGHT: StringName = &"look_right"
const WORLD_MASK: int = 1

@export var tuning: LockOnTuning
## Sphere Area3D that detects LockOnTargets; its radius is set from lock_range.
@export var sensor: Area3D
## Camera that defines "in front" and "left/right" for picking.
@export var camera: Camera3D
## The player's body, excluded from line-of-sight rays.
@export var body: CollisionObject3D
## Height of the player's eyes for line-of-sight checks.
@export_range(0.0, 3.0, 0.05, "suffix:m") var eye_height: float = 1.5

var _target: LockOnTarget
var _cooldown: float = 0.0
var _no_sight_time: float = 0.0
var _mouse_accum: float = 0.0
var _stick_armed: bool = true


func _ready() -> void:
	assert(tuning != null, "LockOnController needs a LockOnTuning resource.")
	assert(sensor != null and camera != null, "LockOnController needs its sensor and camera.")
	sensor.collision_layer = 0
	sensor.collision_mask = LockOnTarget.LAYER
	sensor.monitoring = true
	sensor.monitorable = false
	for child: Node in sensor.get_children():
		var col: CollisionShape3D = child as CollisionShape3D
		if col != null and col.shape is SphereShape3D:
			(col.shape as SphereShape3D).radius = tuning.lock_range


func _physics_process(delta: float) -> void:
	tick(delta)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(ACTION_LOCK):
		toggle_lock()
	elif event.is_action_pressed(ACTION_SWITCH_LEFT):
		switch_target(-1)
	elif event.is_action_pressed(ACTION_SWITCH_RIGHT):
		switch_target(1)
	elif event is InputEventMouseMotion and is_locked():
		add_mouse_motion((event as InputEventMouseMotion).relative)


func is_locked() -> bool:
	return _target != null


func get_target() -> LockOnTarget:
	return _target


## Locks onto the best candidate, or releases the current lock.
func toggle_lock() -> void:
	if is_locked():
		release(ReleaseReason.BUTTON)
		return
	var candidates: Array[LockOnTarget] = _candidates()
	var index: int = LockOnMath.pick_best(
		_origin(), camera.global_basis, _positions(candidates), tuning
	)
	if index != LockOnMath.NONE:
		_set_target(candidates[index])
		target_locked.emit(_target)


## Switches to the neighbor on the left (-1) or right (+1). Returns true if it switched.
func switch_target(direction: int) -> bool:
	if not is_locked() or _cooldown > 0.0 or direction == 0:
		return false
	var candidates: Array[LockOnTarget] = _candidates()
	var index: int = LockOnMath.pick_neighbor(
		_origin(),
		camera.global_basis,
		_target.global_position,
		_positions(candidates),
		direction,
		tuning
	)
	if index == LockOnMath.NONE:
		return false
	_set_target(candidates[index])
	_cooldown = tuning.switch_cooldown
	target_switched.emit(_target)
	return true


## Horizontal mouse travel while locked; a fast enough flick switches target.
func add_mouse_motion(relative: Vector2) -> void:
	_mouse_accum += relative.x
	var direction: int = LockOnMath.switch_direction(_mouse_accum, tuning.mouse_switch_threshold)
	if direction != 0:
		_mouse_accum = 0.0
		switch_target(direction)


func release(reason: ReleaseReason) -> void:
	if not is_locked():
		return
	if _target.tree_exiting.is_connected(_on_target_exiting):
		_target.tree_exiting.disconnect(_on_target_exiting)
	_target = null
	target_released.emit(reason)


## Advances timers, stick flicks and automatic release checks.
func tick(delta: float) -> void:
	_cooldown = maxf(0.0, _cooldown - delta)
	_mouse_accum = move_toward(_mouse_accum, 0.0, tuning.mouse_switch_threshold * 4.0 * delta)
	if not is_locked():
		return
	_read_stick()
	if not is_locked():
		return
	if _target.health != null and _target.health.is_dead():
		release(ReleaseReason.TARGET_LOST)  # the body may linger, but it is no target
		return
	if LockOnMath.is_out_of_range(_origin(), _target.global_position, tuning):
		release(ReleaseReason.OUT_OF_RANGE)
		return
	_no_sight_time = 0.0 if _has_line_of_sight() else _no_sight_time + delta
	if _no_sight_time > tuning.line_of_sight_grace:
		release(ReleaseReason.NO_LINE_OF_SIGHT)


func _read_stick() -> void:
	var x: float = Input.get_axis(ACTION_LOOK_LEFT, ACTION_LOOK_RIGHT)
	var direction: int = LockOnMath.switch_direction(x, tuning.stick_switch_threshold)
	if direction == 0:
		_stick_armed = true
	elif _stick_armed:
		_stick_armed = false
		switch_target(direction)


func _has_line_of_sight() -> bool:
	var from: Vector3 = _origin() + Vector3.UP * eye_height
	var query := PhysicsRayQueryParameters3D.create(from, _target.get_aim_point(), WORLD_MASK)
	if body != null:
		query.exclude = [body.get_rid()]
	var hit: Dictionary = get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		return true
	var collider: Node = hit["collider"] as Node
	return collider != null and _target.get_parent() == collider


func _set_target(target: LockOnTarget) -> void:
	if _target != null and _target.tree_exiting.is_connected(_on_target_exiting):
		_target.tree_exiting.disconnect(_on_target_exiting)
	_target = target
	_no_sight_time = 0.0
	_target.tree_exiting.connect(_on_target_exiting)


func _on_target_exiting() -> void:
	release(ReleaseReason.TARGET_LOST)


func _candidates() -> Array[LockOnTarget]:
	var result: Array[LockOnTarget] = []
	for area: Area3D in sensor.get_overlapping_areas():
		var target: LockOnTarget = area as LockOnTarget
		if target != null:
			result.append(target)
	return result


func _positions(targets: Array[LockOnTarget]) -> Array[Vector3]:
	var result: Array[Vector3] = []
	for t: LockOnTarget in targets:
		result.append(t.global_position)
	return result


func _origin() -> Vector3:
	return global_position
