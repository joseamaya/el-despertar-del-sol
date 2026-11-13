class_name LocomotionMath
extends RefCounted
## Pure locomotion helpers with no node access, so they can be unit tested.

const _MIN_DIRECTION_SQ: float = 0.0001


## Converts move input (x = right, y = back, as from Input.get_vector) into a world-space
## direction on the XZ plane relative to the camera yaw. Keeps analog magnitude, max 1.
static func camera_relative_direction(input: Vector2, camera_basis: Basis) -> Vector3:
	var clamped: Vector2 = input.limit_length(1.0)
	var forward: Vector3 = _flatten(-camera_basis.z)
	if forward.length_squared() < _MIN_DIRECTION_SQ:
		# Camera looking straight down: screen-up is the camera's local Y.
		forward = _flatten(camera_basis.y)
	var right: Vector3 = _flatten(camera_basis.x)
	return right.normalized() * clamped.x - forward.normalized() * clamped.y


## Target horizontal velocity for a direction (magnitude 0..1) and sprint state.
static func target_velocity(direction: Vector3, sprinting: bool, tuning: MovementTuning) -> Vector3:
	var top_speed: float = tuning.sprint_speed if sprinting else tuning.run_speed
	return direction * top_speed


## Moves the horizontal part of `current` toward `target`, keeping current.y.
## Uses `deceleration` when there is no target movement, `acceleration` otherwise.
static func approach_horizontal(
	current: Vector3, target: Vector3, acceleration: float, deceleration: float, delta: float
) -> Vector3:
	var horizontal := Vector3(current.x, 0.0, current.z)
	var flat_target := Vector3(target.x, 0.0, target.z)
	var rate: float = (
		deceleration if flat_target.length_squared() < _MIN_DIRECTION_SQ else acceleration
	)
	var result: Vector3 = horizontal.move_toward(flat_target, rate * delta)
	result.y = current.y
	return result


## Direction to face while locked on (ground plane). Faces the target when idle or moving
## roughly toward it (within `max_angle`); otherwise faces the move direction, so the
## forward run cycle never slides sideways (no strafe clips yet).
static func locked_facing(move_dir: Vector3, to_target: Vector3, max_angle: float) -> Vector3:
	var move_flat: Vector3 = _flatten(move_dir)
	var target_flat: Vector3 = _flatten(to_target)
	if target_flat.length_squared() < _MIN_DIRECTION_SQ:
		return move_flat
	if move_flat.length_squared() < _MIN_DIRECTION_SQ:
		return target_flat
	return target_flat if move_flat.angle_to(target_flat) <= max_angle else move_flat


## Yaw (rotation.y) that makes a node's -Z axis face `direction`.
static func yaw_from_direction(direction: Vector3) -> float:
	return atan2(-direction.x, -direction.z)


## Frame-rate independent exponential turn from `current_yaw` toward `target_yaw`.
static func smooth_yaw(
	current_yaw: float, target_yaw: float, sharpness: float, delta: float
) -> float:
	var weight: float = 1.0 - exp(-sharpness * delta)
	return lerp_angle(current_yaw, target_yaw, weight)


static func _flatten(v: Vector3) -> Vector3:
	return Vector3(v.x, 0.0, v.z)
