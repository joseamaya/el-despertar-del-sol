class_name EnemyGuard
extends HitDefense
## An enemy's occasional block (GDD §7.2). While raised, frontal hits do no damage but add
## part of their posture damage, so pressing a blocking enemy still breaks it.

signal blocked(info: HitInfo)

@export var data: EnemyData
@export var body: Node3D
@export var posture: PostureComponent

var blocking: bool = false


func _ready() -> void:
	assert(data != null and body != null, "EnemyGuard needs data and body.")


func resolve_hit(info: HitInfo) -> DefenseRules.Outcome:
	if not blocking:
		return DefenseRules.Outcome.HIT
	var origin: Vector3 = body.global_position
	var to_attacker: Vector3 = (
		(info.attacker.global_position - origin)
		if info.attacker != null and is_instance_valid(info.attacker)
		else -info.direction
	)
	var forward: Vector3 = body.global_basis * Vector3.FORWARD
	if not DefenseRules.is_frontal(forward, to_attacker, data.block_arc_deg):
		return DefenseRules.Outcome.HIT
	if posture != null:
		posture.apply(info.posture_damage * data.block_posture_factor)
	blocked.emit(info)
	return DefenseRules.Outcome.BLOCKED
