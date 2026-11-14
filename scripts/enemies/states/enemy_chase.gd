class_name EnemyChase
extends State
## Runs to the target along the navmesh until it is at engage distance. When the target
## is not currently sensed it goes to the last known position and waits there until the
## perception gives up (then Idle walks home).


func enter(_previous: StringName) -> void:
	_enemy().clear_face()


func physics_update(_delta: float) -> StringName:
	var enemy: EnemyController = _enemy()
	if not enemy.perception.has_target():
		return &"idle"
	var goal: Vector3 = enemy.perception.last_known_position
	if not enemy.perception.can_sense():
		enemy.move_to(goal, enemy.data.run_speed)
		return &""
	if enemy.distance_to(goal) <= enemy.data.engage_distance:
		return &"strafe"
	enemy.move_to(goal, enemy.data.run_speed)
	return &""


func _enemy() -> EnemyController:
	return machine.context as EnemyController
