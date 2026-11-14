class_name EnemyBlock
extends State
## Raises the guard for a moment after being hit (GDD §7.2: occasional block).

var _time_left: float = 0.0


func enter(_previous: StringName) -> void:
	var enemy: EnemyController = _enemy()
	enemy.stop()
	enemy.guard.blocking = true
	_time_left = enemy.data.block_time


func exit() -> void:
	_enemy().guard.blocking = false
	_enemy().clear_face()


func physics_update(delta: float) -> StringName:
	var enemy: EnemyController = _enemy()
	enemy.stop()
	if enemy.perception.has_target():
		enemy.face(enemy.perception.last_known_position)
	_time_left -= delta
	return &"strafe" if _time_left <= 0.0 else &""


func _enemy() -> EnemyController:
	return machine.context as EnemyController
