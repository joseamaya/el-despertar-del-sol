class_name EnemyDead
extends State
## Stops, stops colliding and being targetable, plays the death clip and disappears.

@export var death_clip: StringName = &"Death01"
## Collision objects (hurtbox, lock-on target, body) disabled on death.
@export var disable_on_death: Array[CollisionObject3D] = []

var _time_left: float = 0.0


func enter(_previous: StringName) -> void:
	var enemy: EnemyController = _enemy()
	enemy.stop()
	enemy.clear_face()
	enemy.show_alert(false)
	for object: CollisionObject3D in disable_on_death:
		object.collision_layer = 0
		object.collision_mask = 0
	if enemy.animator != null:
		enemy.animator.play_attack(death_clip, 1.0)
	_time_left = enemy.data.corpse_time


func physics_update(delta: float) -> StringName:
	_time_left -= delta
	if _time_left <= 0.0:
		_enemy().queue_free()
	return &""


func _enemy() -> EnemyController:
	return machine.context as EnemyController
