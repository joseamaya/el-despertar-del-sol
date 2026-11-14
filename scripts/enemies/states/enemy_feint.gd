class_name EnemyFeint
extends State
## A quick step toward the target without swinging, then back (GDD §6.6: feints). Used when
## the director refuses an attack token.

var _forward_left: float = 0.0
var _back_left: float = 0.0


func enter(_previous: StringName) -> void:
	var data: EnemyData = _enemy().data
	_forward_left = data.feint_distance / maxf(data.feint_speed, 0.01)
	_back_left = _forward_left


func exit() -> void:
	_enemy().stop()


func physics_update(delta: float) -> StringName:
	var enemy: EnemyController = _enemy()
	if not enemy.perception.has_target():
		return &"idle"
	var target: Vector3 = enemy.perception.last_known_position
	var toward: Vector3 = target - enemy.global_position
	enemy.face(target)
	if _forward_left > 0.0:
		_forward_left -= delta
		var close: bool = enemy.distance_to(target) <= enemy.data.attack_contact_distance
		enemy.move_direction(toward, 0.0 if close else enemy.data.feint_speed)
		return &""
	_back_left -= delta
	enemy.move_direction(-toward, enemy.data.feint_speed)
	return &"strafe" if _back_left <= 0.0 else &""


func _enemy() -> EnemyController:
	return machine.context as EnemyController
