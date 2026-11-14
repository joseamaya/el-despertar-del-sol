class_name PlayerController
extends CharacterBody3D
## Camera-relative locomotion: walk/run by stick deflection, sprint, acceleration and facing.
## Values come from a MovementTuning resource; the reference camera is injected.

const ACTION_MOVE_LEFT: StringName = &"move_left"
const ACTION_MOVE_RIGHT: StringName = &"move_right"
const ACTION_MOVE_FORWARD: StringName = &"move_forward"
const ACTION_MOVE_BACK: StringName = &"move_back"
const ACTION_SPRINT: StringName = &"sprint"

const _FACING_MIN_SQ: float = 0.0001

@export var tuning: MovementTuning
## Camera whose yaw defines "forward". Without one, world -Z is forward.
@export var camera: Camera3D
## Optional: sprinting spends it, and an empty bar stops the sprint (DECISIONS/0007).
@export var stamina: StaminaComponent

## Last move input read, x = right, y = back. Exposed for debugging and animation later.
var move_input: Vector2 = Vector2.ZERO
var is_sprinting: bool = false
## After stamina runs out, sprint needs a fresh press (avoids flickering at zero).
var _sprint_locked: bool = false

## When set (lock-on), the player faces it while idle or moving toward it, and turns to
## its move direction when going sideways or away (see LocomotionMath.locked_facing).
var _face_target: Node3D

## During an action (attack) input movement is ignored and the action drives velocity.
var _in_action: bool = false
var _action_velocity: Vector3 = Vector3.ZERO
var _action_tracks_target: bool = true
## Max horizontal speed (e.g. while blocking); negative = no limit.
var _speed_limit: float = -1.0


func _ready() -> void:
	assert(tuning != null, "PlayerController needs a MovementTuning resource.")


func _physics_process(delta: float) -> void:
	_read_input()
	var reference_basis: Basis = camera.global_basis if camera != null else Basis.IDENTITY
	var direction: Vector3 = LocomotionMath.camera_relative_direction(move_input, reference_basis)
	var target: Vector3 = LocomotionMath.target_velocity(direction, is_sprinting, tuning)
	if _speed_limit >= 0.0:
		is_sprinting = false
		target = target.limit_length(_speed_limit)

	if _in_action:
		_physics_in_action(delta)
		return

	if is_sprinting and stamina != null:
		stamina.drain_over_time(tuning.sprint_stamina_per_second, delta)
		if stamina.is_empty():
			_sprint_locked = true

	velocity = LocomotionMath.approach_horizontal(
		velocity, target, tuning.acceleration, tuning.deceleration, delta
	)
	if not is_on_floor():
		velocity.y -= tuning.gravity * delta
	move_and_slide()

	if _face_target != null and not is_instance_valid(_face_target):
		_face_target = null
	var facing: Vector3 = direction
	if _face_target != null:
		facing = LocomotionMath.locked_facing(
			direction,
			_face_target.global_position - global_position,
			deg_to_rad(tuning.lock_face_max_angle_deg)
		)
	if facing.length_squared() > _FACING_MIN_SQ:
		var target_yaw: float = LocomotionMath.yaw_from_direction(facing)
		rotation.y = LocomotionMath.smooth_yaw(rotation.y, target_yaw, tuning.turn_sharpness, delta)


## Starts an action (attack, dodge, stun). Faces `direction` if given; otherwise, when
## `track_target`, the lock target, else the move input, else keeps the current facing.
## With `track_target` false the body does not turn toward the lock target meanwhile.
## Movement input is ignored until end_action().
func begin_action(direction: Vector3 = Vector3.ZERO, track_target: bool = true) -> void:
	_in_action = true
	_action_tracks_target = track_target
	is_sprinting = false
	_action_velocity = Vector3.ZERO
	var facing: Vector3 = Vector3(direction.x, 0.0, direction.z)
	if facing.is_zero_approx() and track_target:
		if _face_target != null and is_instance_valid(_face_target):
			facing = _face_target.global_position - global_position
			facing.y = 0.0
		else:
			facing = get_move_direction()
	if facing.length_squared() > _FACING_MIN_SQ:
		rotation.y = LocomotionMath.yaw_from_direction(facing)


## Horizontal velocity imposed by the action (e.g. an attack's lunge).
func set_action_velocity(value: Vector3) -> void:
	_action_velocity = Vector3(value.x, 0.0, value.z)


func end_action() -> void:
	_in_action = false
	_action_velocity = Vector3.ZERO


## Caps horizontal speed (e.g. 2 m/s while blocking). Negative removes the cap.
func set_speed_limit(value: float) -> void:
	_speed_limit = value


## Camera-relative direction of the current move input (zero without input).
func get_move_direction() -> Vector3:
	var reference: Basis = camera.global_basis if camera != null else Basis.IDENTITY
	return LocomotionMath.camera_relative_direction(_current_move_input(), reference)


func is_in_action() -> bool:
	return _in_action


## Flat forward direction the body faces.
func get_action_forward() -> Vector3:
	var forward: Vector3 = global_basis * Vector3.FORWARD
	forward.y = 0.0
	return forward.normalized()


## Keeps facing `target` (connect LockOnController.target_locked / target_switched).
func set_face_target(target: Node3D) -> void:
	_face_target = target


## Back to facing the move direction (connect LockOnController.target_released).
func release_face_target(_reason: int = 0) -> void:
	_face_target = null


## Puts the player back at `at` (facing `yaw`), with control and no leftover motion.
## Health and stamina are reset by whoever owns the encounter.
func respawn(at: Vector3, yaw: float) -> void:
	end_action()
	set_speed_limit(-1.0)
	_face_target = null
	velocity = Vector3.ZERO
	global_position = at
	rotation.y = yaw


## Horizontal speed in m/s, ignoring falling.
func get_horizontal_speed() -> float:
	return Vector2(velocity.x, velocity.z).length()


func _physics_in_action(delta: float) -> void:
	velocity.x = _action_velocity.x
	velocity.z = _action_velocity.z
	if not is_on_floor():
		velocity.y -= tuning.gravity * delta
	move_and_slide()
	if _action_tracks_target and _face_target != null and is_instance_valid(_face_target):
		var to_target: Vector3 = _face_target.global_position - global_position
		to_target.y = 0.0
		if to_target.length_squared() > _FACING_MIN_SQ:
			var yaw: float = LocomotionMath.yaw_from_direction(to_target)
			rotation.y = LocomotionMath.smooth_yaw(rotation.y, yaw, tuning.turn_sharpness, delta)


func _current_move_input() -> Vector2:
	return Input.get_vector(
		ACTION_MOVE_LEFT, ACTION_MOVE_RIGHT, ACTION_MOVE_FORWARD, ACTION_MOVE_BACK
	)


func _read_input() -> void:
	move_input = _current_move_input()
	var held: bool = Input.is_action_pressed(ACTION_SPRINT)
	if not held:
		_sprint_locked = false
	var has_stamina: bool = stamina == null or not stamina.is_empty()
	if held and not has_stamina:
		_sprint_locked = true
	is_sprinting = held and has_stamina and not _sprint_locked and not move_input.is_zero_approx()
