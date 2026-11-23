class_name BlockProbe
extends Node
## Diagnostic helper (F6 task 2): while the player holds block, counts what each incoming
## blow does (blocked, parried, guard broken, landed) and, for every blow that lands, why
## the guard did not stop it: from outside the frontal arc, while attacking, while stunned
## after a broken guard, or with block not held. Also keeps the angle of every blow
## relative to where the player faced. Not part of the game: tools/block_diagnosis.gd
## adds it.

const ACTION_BLOCK: StringName = &"block"
## Why a blow landed.
const OUTSIDE_ARC: String = "fuera_del_arco"
const ATTACKING: String = "atacando"
const STUNNED: String = "aturdido"
const NOT_HELD: String = "sin_bloquear"
const DODGING: String = "esquivando"
const OTHER: String = "otro"

@export var player: PlayerController

var blocked: int = 0
var parried: int = 0
var guard_broken: int = 0
var evaded: int = 0
var landed: Dictionary = {}
## Angle in degrees between the player's facing and each attacker, for every blow.
var angles: PackedFloat32Array = PackedFloat32Array()

var _defense: DefenseComponent
var _combat: CombatComponent


func _ready() -> void:
	assert(player != null, "BlockProbe needs the player.")
	_defense = player.get_node(^"Defense") as DefenseComponent
	_combat = player.get_node(^"Combat") as CombatComponent
	_defense.blocked.connect(_on_resolved.bind(&"blocked"))
	_defense.parried.connect(_on_resolved.bind(&"parried"))
	_defense.evaded.connect(_on_resolved.bind(&"evaded"))
	_defense.guard_broken.connect(func() -> void: guard_broken += 1)
	(player.get_node(^"Hurtbox") as Hurtbox).hit_received.connect(_on_landed)


## Blows that reached the player, whatever they did.
func blows() -> int:
	return blocked + parried + guard_broken + evaded + landed_total()


func landed_total() -> int:
	var total: int = 0
	for reason: String in landed:
		total += landed[reason] as int
	return total


func report() -> Dictionary:
	return {
		"blows": blows(),
		"blocked": blocked,
		"parried": parried,
		"guard_broken": guard_broken,
		"evaded": evaded,
		"landed": landed.duplicate(),
		"angles": Array(angles),
	}


## Why a blow from `info` got through the guard right now.
func reason_for(info: HitInfo) -> String:
	if _defense.is_dodging():
		return DODGING
	if _defense.is_stunned():
		return STUNNED
	if not Input.is_action_pressed(ACTION_BLOCK):
		return NOT_HELD
	if _combat.is_attacking():
		return ATTACKING
	if absf(_angle_to(info)) > _defense.tuning.block_arc_deg * 0.5:
		return OUTSIDE_ARC
	return OTHER


func _on_resolved(info: HitInfo, kind: StringName) -> void:
	angles.append(_angle_to(info))
	match kind:
		&"blocked":
			blocked += 1
		&"parried":
			parried += 1
		&"evaded":
			evaded += 1


func _on_landed(info: HitInfo) -> void:
	# A broken guard also lands nothing (guard_broken counts it); the rest landed.
	var reason: String = reason_for(info)
	angles.append(_angle_to(info))
	landed[reason] = (landed.get(reason, 0) as int) + 1


func _angle_to(info: HitInfo) -> float:
	var to: Vector3 = info.point - player.global_position
	if info.attacker != null and is_instance_valid(info.attacker):
		to = info.attacker.global_position - player.global_position
	to.y = 0.0
	var facing: Vector3 = player.get_action_forward()
	if to.length_squared() < 0.0001:
		return 0.0
	return rad_to_deg(facing.signed_angle_to(to.normalized(), Vector3.UP))
