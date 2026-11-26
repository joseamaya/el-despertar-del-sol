class_name EnemyPatrol
extends State
## Walks the patrol route in a loop, waiting a moment at each point. Entering (at the start,
## or back from a chase that lost the target) it heads for the nearest point of the route,
## so a scout that lost Cusi goes back to its round (F9 task 12).

var _index: int = 0
var _wait_left: float = 0.0


func enter(_previous: StringName) -> void:
	var enemy: EnemyController = _enemy()
	enemy.clear_face()
	_wait_left = 0.0
	_index = nearest_point(enemy.patrol_points, enemy.global_position)


func physics_update(delta: float) -> StringName:
	var enemy: EnemyController = _enemy()
	if enemy.perception.has_target():
		return &"alert"
	if enemy.patrol_points.is_empty():
		return &"idle"
	if _wait_left > 0.0:
		_wait_left -= delta
		enemy.stop()
		return &""
	if enemy.move_to(enemy.patrol_points[_index], enemy.data.walk_speed):
		_index = (_index + 1) % enemy.patrol_points.size()
		_wait_left = enemy.data.patrol_wait
	return &""


func patrol_index() -> int:
	return _index


## Index of the point of `route` nearest to `from` on the ground (0 if the route is empty).
static func nearest_point(route: Array[Vector3], from: Vector3) -> int:
	var best: int = 0
	var best_distance: float = INF
	for i: int in route.size():
		var d: float = Vector2(route[i].x - from.x, route[i].z - from.z).length_squared()
		if d < best_distance:
			best_distance = d
			best = i
	return best


func _enemy() -> EnemyController:
	return machine.context as EnemyController
