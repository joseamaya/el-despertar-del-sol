class_name LockOnMath
extends RefCounted
## Pure lock-on rules: candidate scoring, left/right neighbors and switch gestures.
## Directions are measured on the ground plane from the camera's point of view.

const NONE: int = -1


## Signed horizontal angle (radians) of `point` seen from `origin`, relative to the camera
## view. Positive = to the camera's right.
static func view_angle(origin: Vector3, point: Vector3, camera_basis: Basis) -> float:
	var to_point := Vector3(point.x - origin.x, 0.0, point.z - origin.z)
	var forward := Vector3(-camera_basis.z.x, 0.0, -camera_basis.z.z)
	var right := Vector3(camera_basis.x.x, 0.0, camera_basis.x.z)
	return atan2(to_point.dot(right.normalized()), to_point.dot(forward.normalized()))


## Index of the best candidate to lock onto, or NONE. Prefers centered, then close.
static func pick_best(
	origin: Vector3, camera_basis: Basis, candidates: Array[Vector3], tuning: LockOnTuning
) -> int:
	var best: int = NONE
	var best_score: float = INF
	var max_angle: float = deg_to_rad(tuning.max_pick_angle_deg)
	for i: int in candidates.size():
		var distance: float = _flat_distance(origin, candidates[i])
		var angle: float = absf(view_angle(origin, candidates[i], camera_basis))
		if distance > tuning.lock_range or angle > max_angle:
			continue
		var score: float = angle / max_angle + tuning.distance_weight * distance / tuning.lock_range
		if score < best_score:
			best_score = score
			best = i
	return best


## Index of the nearest candidate to the left (direction -1) or right (+1) of `current`
## on screen, within lock range, or NONE if there is none on that side.
static func pick_neighbor(
	origin: Vector3,
	camera_basis: Basis,
	current: Vector3,
	candidates: Array[Vector3],
	direction: int,
	tuning: LockOnTuning
) -> int:
	var current_angle: float = view_angle(origin, current, camera_basis)
	var best: int = NONE
	var best_gap: float = INF
	for i: int in candidates.size():
		if candidates[i].is_equal_approx(current):
			continue
		if _flat_distance(origin, candidates[i]) > tuning.lock_range:
			continue
		var gap: float = (
			(view_angle(origin, candidates[i], camera_basis) - current_angle) * direction
		)
		if gap > 0.0 and gap < best_gap:
			best_gap = gap
			best = i
	return best


## -1, 0 or +1 from an axis value against a threshold (stick deflection or mouse pixels).
static func switch_direction(value: float, threshold: float) -> int:
	if absf(value) < threshold:
		return 0
	return 1 if value > 0.0 else -1


static func is_out_of_range(origin: Vector3, target: Vector3, tuning: LockOnTuning) -> bool:
	return _flat_distance(origin, target) > tuning.break_distance


static func _flat_distance(a: Vector3, b: Vector3) -> float:
	return Vector2(b.x - a.x, b.z - a.z).length()
