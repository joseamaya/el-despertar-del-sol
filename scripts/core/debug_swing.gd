class_name DebugSwing
extends Node3D
## Test-scene helper until real attacks exist (F2 task 4): J swings a placeholder champi
## in an arc in front of the player through its Hitbox. Place it as a child of the player.

@export var hitbox: Hitbox
@export var attacker: Node3D
@export_range(1.0, 100.0, 1.0) var damage: float = 15.0
## Arc swept in front of the player, degrees from left to right.
@export_range(10.0, 270.0, 1.0, "suffix:°") var arc_deg: float = 200.0
@export_range(0.02, 1.0, 0.01, "suffix:s") var swing_time: float = 0.12

var _swinging: bool = false


func _ready() -> void:
	assert(hitbox != null, "DebugSwing needs a Hitbox.")
	visible = false


func _unhandled_key_input(event: InputEvent) -> void:
	var key: InputEventKey = event as InputEventKey
	if key != null and key.pressed and not key.echo and key.physical_keycode == KEY_J:
		swing()


## Starts a swing; returns false if one is already running. Public for tests.
func swing() -> bool:
	if _swinging:
		return false
	_swinging = true
	visible = true
	var half: float = deg_to_rad(arc_deg) * 0.5
	rotation.y = half
	hitbox.activate(HitInfo.create(damage, 0.0, attacker))
	var tween: Tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.tween_property(self, "rotation:y", -half, swing_time)
	await tween.finished
	hitbox.sweep()
	hitbox.deactivate()
	visible = false
	_swinging = false
	return true


func is_swinging() -> bool:
	return _swinging
