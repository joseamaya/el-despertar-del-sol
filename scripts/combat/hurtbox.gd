class_name Hurtbox
extends Area3D
## Body area that can be hit. Lives on the hurtbox physics layer; passes damage to the
## injected HealthComponent and reports every hit. Needs a CollisionShape3D child.

signal hit_received(info: HitInfo)

@export var faction: HitRules.Faction = HitRules.Faction.NEUTRAL
## Optional: receives the damage. Without it the hurtbox only reports hits.
@export var health: HealthComponent
## Optional: block, parry and dodge decide first whether the hit lands.
@export var defense: HitDefense
## Optional: takes each landed hit's posture damage (enemies, GDD §6.4).
@export var posture: PostureComponent


func _ready() -> void:
	collision_layer = HitRules.HURTBOX_LAYER
	collision_mask = 0
	monitoring = false
	monitorable = true


## Whether this target can be executed now (posture broken, still alive).
func is_executable() -> bool:
	return posture != null and posture.is_broken() and (health == null or not health.is_dead())


## Called by a Hitbox. Ignored once the owner is dead; blocked, parried or evaded hits
## do no damage and are reported by the defense (HitDefense) instead.
func receive_hit(info: HitInfo) -> void:
	if health != null and health.is_dead():
		return
	if (
		defense != null
		and not info.unblockable
		and defense.resolve_hit(info) != DefenseRules.Outcome.HIT
	):
		return
	if health != null:
		health.apply_damage(info.damage)
	if posture != null:
		posture.apply(info.posture_damage)
	hit_received.emit(info)
