class_name EnemyRetreat
extends State
## Backs off after a heavy hit (GDD §7.2), still facing the target.

var _time_left: float = 0.0
var _direction: Vector3 = Vector3.ZERO


func enter(_previous: StringName) -> void:
	var enemy: EnemyController = _enemy()
	var away: Vector3 = enemy.global_position - enemy.perception.last_known_position
	away.y = 0.0
	if away.length_squared() < 0.0001:
		away = -(enemy.global_basis * Vector3.FORWARD)
	_direction = away.normalized()
	_time_left = enemy.data.retreat_distance / maxf(enemy.data.retreat_speed, 0.01)


func exit() -> void:
	_enemy().stop()
	_enemy().clear_face()


func physics_update(delta: float) -> StringName:
	var enemy: EnemyController = _enemy()
	enemy.face(enemy.perception.last_known_position)
	enemy.move_direction(_direction, enemy.data.retreat_speed)
	_time_left -= delta
	return &"strafe" if _time_left <= 0.0 else &""


func _enemy() -> EnemyController:
	return machine.context as EnemyController
