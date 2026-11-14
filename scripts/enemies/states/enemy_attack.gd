class_name EnemyAttack
extends State
## Closes to attack range, faces the target and swings; back to circling when done.

var _swinging: bool = false


func enter(_previous: StringName) -> void:
	_swinging = false


func exit() -> void:
	var enemy: EnemyController = _enemy()
	if enemy.combat.is_attacking():
		enemy.combat.cancel()
	if enemy.director != null:
		enemy.director.release_token(enemy)
	enemy.clear_face()


func physics_update(_delta: float) -> StringName:
	var enemy: EnemyController = _enemy()
	if _swinging:
		return &"" if enemy.combat.is_attacking() else &"strafe"
	if not enemy.perception.has_target():
		return &"idle"
	var target: Vector3 = enemy.perception.last_known_position
	enemy.face(target)
	if enemy.distance_to(target) > enemy.data.attack_range:
		enemy.move_to(target, enemy.data.run_speed)
		return &""
	enemy.stop()
	enemy.combat.start()
	_swinging = true
	return &""


func _enemy() -> EnemyController:
	return machine.context as EnemyController
