class_name Hurtbox
extends Area3D
## Body area that can be hit. Lives on the hurtbox physics layer; passes damage to the
## injected HealthComponent and reports every hit. Needs a CollisionShape3D child.

signal hit_received(info: HitInfo)

@export var faction: HitRules.Faction = HitRules.Faction.NEUTRAL
## Optional: receives the damage. Without it the hurtbox only reports hits.
@export var health: HealthComponent
## Optional: block, parry and dodge decide first whether the hit lands.
@export var defense: DefenseComponent


func _ready() -> void:
	collision_layer = HitRules.HURTBOX_LAYER
	collision_mask = 0
	monitoring = false
	monitorable = true


## Called by a Hitbox. Ignored once the owner is dead; blocked, parried or evaded hits
## do no damage and are reported by the DefenseComponent instead.
func receive_hit(info: HitInfo) -> void:
	if health != null and health.is_dead():
		return
	if defense != null and defense.resolve_hit(info) != DefenseRules.Outcome.HIT:
		return
	if health != null:
		health.apply_damage(info.damage)
	hit_received.emit(info)
