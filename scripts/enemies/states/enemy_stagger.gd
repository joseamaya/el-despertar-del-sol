class_name EnemyStagger
extends State
## Posture broken: stands still, executable, until the posture recovers (GDD §6.4).


func enter(_previous: StringName) -> void:
	if _enemy().combat != null:
		_enemy().combat.cancel()
	_enemy().stop()
	_enemy().clear_face()


func physics_update(_delta: float) -> StringName:
	var enemy: EnemyController = _enemy()
	enemy.stop()
	if enemy.posture != null and enemy.posture.is_broken():
		return &""
	return &"chase" if enemy.perception.has_target() else &"idle"


func _enemy() -> EnemyController:
	return machine.context as EnemyController
