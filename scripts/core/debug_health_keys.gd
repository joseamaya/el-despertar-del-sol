class_name DebugHealthKeys
extends Node
## Test-scene helper until hits exist (F2 task 3): K deals damage, L restores health.
## Lives only in test scenes, never in the player.

@export var health: HealthComponent
@export_range(1.0, 100.0, 1.0) var damage: float = 10.0


func _unhandled_key_input(event: InputEvent) -> void:
	var key: InputEventKey = event as InputEventKey
	if key != null and key.pressed and not key.echo:
		handle_key(key.physical_keycode)


## Public so tests can drive it without input events. Returns true if the key was used.
func handle_key(keycode: Key) -> bool:
	if health == null:
		return false
	if keycode == KEY_K:
		health.apply_damage(damage)
		return true
	if keycode == KEY_L:
		health.reset()
		return true
	return false
