class_name EnemyAlert
extends State
## Reaction before chasing: stops, turns to the target and shows the "!" (GDD §12.4).

var _time: float = 0.0


func enter(_previous: StringName) -> void:
	_time = 0.0
	_enemy().stop()
	_enemy().show_alert(true)


func exit() -> void:
	_enemy().show_alert(false)


func physics_update(delta: float) -> StringName:
	var enemy: EnemyController = _enemy()
	if not enemy.perception.has_target():
		return &"idle"
	enemy.face(enemy.perception.last_known_position)
	_time += delta
	return &"chase" if _time >= enemy.data.alert_time else &""


func _enemy() -> EnemyController:
	return machine.context as EnemyController
