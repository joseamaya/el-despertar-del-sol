class_name EnemyIdle
extends State
## Stands guard at home (walking back if displaced) or starts a patrol; alerts on sight.


func enter(_previous: StringName) -> void:
	_enemy().clear_face()


func physics_update(_delta: float) -> StringName:
	var enemy: EnemyController = _enemy()
	if enemy.perception.has_target():
		return &"alert"
	if not enemy.patrol_points.is_empty():
		return &"patrol"
	enemy.move_to(enemy.home_position, enemy.data.walk_speed)
	return &""


func _enemy() -> EnemyController:
	return machine.context as EnemyController
