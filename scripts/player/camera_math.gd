class_name CameraMath
extends RefCounted
## Pure camera helpers with no node access, so they can be unit tested.
## Look deltas are Vector2(yaw, pitch) in radians. Positive yaw turns left,
## positive pitch looks up (Godot's rotation conventions).


## Look delta from mouse motion in pixels (x right, y down).
static func look_from_mouse(relative: Vector2, tuning: CameraTuning) -> Vector2:
	return _to_look(relative * deg_to_rad(tuning.mouse_sensitivity), tuning)


## Look delta from the right stick (x right, y down, -1..1) over `delta` seconds.
static func look_from_stick(stick: Vector2, delta: float, tuning: CameraTuning) -> Vector2:
	return _to_look(stick * deg_to_rad(tuning.stick_sensitivity) * delta, tuning)


## Applies a look delta to (yaw, pitch): yaw wraps to [-PI, PI], pitch is clamped.
static func apply_look(yaw_pitch: Vector2, look: Vector2, tuning: CameraTuning) -> Vector2:
	var yaw: float = wrapf(yaw_pitch.x + look.x, -PI, PI)
	var pitch: float = clampf(
		yaw_pitch.y + look.y, deg_to_rad(tuning.pitch_min_deg), deg_to_rad(tuning.pitch_max_deg)
	)
	return Vector2(yaw, pitch)


## Frame-rate independent exponential follow from `current` toward `target`.
static func follow(current: Vector3, target: Vector3, sharpness: float, delta: float) -> Vector3:
	return current.lerp(target, 1.0 - exp(-sharpness * delta))


## Yaw that puts the camera behind `from` looking at `to` (ground plane).
static func yaw_towards(from: Vector3, to: Vector3) -> float:
	return atan2(-(to.x - from.x), -(to.z - from.z))


## Frame-rate independent exponential turn of (yaw, pitch) toward a goal.
static func turn_towards(
	yaw_pitch: Vector2, goal: Vector2, sharpness: float, delta: float
) -> Vector2:
	var weight: float = 1.0 - exp(-sharpness * delta)
	return Vector2(lerp_angle(yaw_pitch.x, goal.x, weight), lerpf(yaw_pitch.y, goal.y, weight))


## Screen-space motion (right/down) -> look delta, honoring axis inversion.
static func _to_look(screen: Vector2, tuning: CameraTuning) -> Vector2:
	var yaw: float = -screen.x * (-1.0 if tuning.invert_x else 1.0)
	var pitch: float = -screen.y * (-1.0 if tuning.invert_y else 1.0)
	return Vector2(yaw, pitch)
