class_name EnemyPatrol
extends State
## Walks the patrol route, waiting a moment at each point.

var _index: int = 0
var _wait_left: float = 0.0


func enter(_previous: StringName) -> void:
	_enemy().clear_face()
	_wait_left = 0.0


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


func _enemy() -> EnemyController:
	return machine.context as EnemyController
