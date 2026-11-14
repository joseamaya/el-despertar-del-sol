class_name PerceptionRules
extends RefCounted
## Pure perception rules on the ground plane (GDD §7.1: view cone + hearing radius).


static func in_view_cone(
	origin: Vector3, forward: Vector3, point: Vector3, max_distance: float, angle_deg: float
) -> bool:
	var to_point := Vector3(point.x - origin.x, 0.0, point.z - origin.z)
	var distance: float = to_point.length()
	if distance > max_distance:
		return false
	if distance < 0.001:
		return true
	var flat_forward := Vector3(forward.x, 0.0, forward.z)
	if flat_forward.length_squared() < 0.0001:
		return false
	return flat_forward.angle_to(to_point) <= deg_to_rad(angle_deg) * 0.5


static func heard(origin: Vector3, point: Vector3, radius: float) -> bool:
	return Vector2(point.x - origin.x, point.z - origin.z).length() <= radius
