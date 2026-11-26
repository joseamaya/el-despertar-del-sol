class_name EnemyAttack
extends State
## Closes to attack range, faces the target and swings; back to circling when done. A
## lancer whose target is inside its keep-away distance first steps back (for at most
## `keep_away_max_step` seconds), so the thrust comes from the edge of its reach.

var _swinging: bool = false
var _stepped: float = 0.0


func enter(_previous: StringName) -> void:
	_swinging = false
	_stepped = 0.0


func exit() -> void:
	var enemy: EnemyController = _enemy()
	if enemy.combat.is_attacking():
		enemy.combat.cancel()
	if enemy.director != null:
		enemy.director.release_token(enemy)
	enemy.clear_face()


func physics_update(delta: float) -> StringName:
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
	if _stepped < enemy.data.keep_away_max_step and EnemyStrafe.too_close(enemy, target):
		_stepped += delta
		var away: Vector3 = enemy.global_position - target
		away.y = 0.0
		if away.length_squared() > 0.0001:
			enemy.move_direction(away.normalized(), enemy.data.retreat_speed)
			return &""
	enemy.stop()
	enemy.combat.start()
	_swinging = true
	return &""


func _enemy() -> EnemyController:
	return machine.context as EnemyController
