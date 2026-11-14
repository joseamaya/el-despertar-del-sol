class_name DebugEnemyAttack
extends Node3D
## Test-scene helper until enemies exist (F2 tasks 7–8): H launches a telegraphed chanca
## swing at the target, from the front (Shift+H: from behind). Lets the player practise
## block, parry and dodge.

@export var target: Node3D
@export var hitbox: Hitbox
## Shown during the windup, like an enemy's telegraph (GDD §7.2, §12.4).
@export var telegraph: Node3D
@export_range(1.0, 100.0, 1.0) var damage: float = 15.0
## Anticipation before the swing (GDD §6.5: 0.6–0.8 s for a basic attack).
@export_range(0.0, 2.0, 0.05, "suffix:s") var windup: float = 0.6
@export_range(0.02, 1.0, 0.01, "suffix:s") var swing_time: float = 0.12
## Distance from the target where the attacker stands.
@export_range(0.5, 5.0, 0.1, "suffix:m") var reach: float = 1.6

var _attacking: bool = false


func _ready() -> void:
	assert(target != null and hitbox != null, "DebugEnemyAttack needs target and hitbox.")
	top_level = true
	_show(false)


func _unhandled_key_input(event: InputEvent) -> void:
	var key: InputEventKey = event as InputEventKey
	if key != null and key.pressed and not key.echo and key.physical_keycode == KEY_H:
		attack(key.shift_pressed)


## Starts a telegraphed swing; returns false if one is running. Public for tests.
func attack(from_behind: bool = false) -> bool:
	if _attacking:
		return false
	_attacking = true
	var forward: Vector3 = target.global_basis * Vector3.FORWARD
	forward.y = 0.0
	forward = forward.normalized() * (-1.0 if from_behind else 1.0)
	global_position = target.global_position + forward * reach
	look_at(target.global_position, Vector3.UP)
	hitbox.position = Vector3(0.9, 1.2, -reach)
	_show(true)
	await get_tree().create_timer(windup, false, true).timeout
	if telegraph != null:
		telegraph.visible = false
	hitbox.activate(HitInfo.create(damage, 0.0, self))
	var tween: Tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.tween_property(hitbox, "position:x", -0.9, swing_time)
	await tween.finished
	hitbox.sweep()
	hitbox.deactivate()
	_show(false)
	_attacking = false
	return true


func is_attacking() -> bool:
	return _attacking


func _show(on: bool) -> void:
	visible = on
	if telegraph != null:
		telegraph.visible = on
