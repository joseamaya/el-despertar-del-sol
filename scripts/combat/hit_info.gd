class_name HitInfo
extends RefCounted
## Data of one hit, created by the attacker and delivered to every Hurtbox it touches.

var damage: float = 0.0
## Damage to the target's posture (F2 task 6).
var posture_damage: float = 0.0
var attacker: Node3D
## Where the hit landed, in world space (set by the Hitbox).
var point: Vector3 = Vector3.ZERO
## Direction of the swing at impact, in world space (set by the Hitbox).
var direction: Vector3 = Vector3.ZERO
## The attacker's posture: a parry sends posture damage back to it (GDD §6.1).
var source_posture: PostureComponent
## Executions ignore block, parry and dodge.
var unblockable: bool = false


static func create(damage_amount: float, posture: float = 0.0, source: Node3D = null) -> HitInfo:
	var info := HitInfo.new()
	info.damage = damage_amount
	info.posture_damage = posture
	info.attacker = source
	return info


## Copy for one target, so each hurtbox gets its own point and direction.
func for_target(at: Vector3, towards: Vector3) -> HitInfo:
	var copy := HitInfo.create(damage, posture_damage, attacker)
	copy.point = at
	copy.direction = towards
	copy.source_posture = source_posture
	copy.unblockable = unblockable
	return copy
