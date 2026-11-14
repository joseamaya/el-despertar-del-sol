class_name EnemyStrafe
extends State
## Circles the target at engage distance, facing it and switching direction now and then.
## In F2 task 8 attacks start from here.

var _side: int = 1
var _switch_left: float = 0.0
var _rng := RandomNumberGenerator.new()


func enter(_previous: StringName) -> void:
	_side = 1 if _rng.randf() < 0.5 else -1
	_switch_left = _next_switch()


func exit() -> void:
	_enemy().clear_face()


func physics_update(delta: float) -> StringName:
	var enemy: EnemyController = _enemy()
	if not enemy.perception.has_target():
		return &"idle"
	if not enemy.perception.can_sense():
		return &"chase"  # lost sight: go to where it was last seen
	var target: Vector3 = enemy.perception.last_known_position
	if enemy.distance_to(target) > enemy.data.engage_distance * 1.6:
		return &"chase"
	_switch_left -= delta
	if _switch_left <= 0.0:
		_side = -_side
		_switch_left = _next_switch()
	enemy.face(target)
	enemy.strafe_around(target, enemy.data.engage_distance, _side, enemy.data.strafe_speed)
	return &""


func _next_switch() -> float:
	var data: EnemyData = _enemy().data
	return _rng.randf_range(data.strafe_switch_min, data.strafe_switch_max)


func _enemy() -> EnemyController:
	return machine.context as EnemyController
