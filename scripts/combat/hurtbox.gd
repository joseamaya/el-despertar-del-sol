class_name Hurtbox
extends Area3D
## Body area that can be hit. Lives on the hurtbox physics layer; passes damage to the
## injected HealthComponent and reports every hit. Needs a CollisionShape3D child.

signal hit_received(info: HitInfo)

@export var faction: HitRules.Faction = HitRules.Faction.NEUTRAL
## Optional: receives the damage. Without it the hurtbox only reports hits.
@export var health: HealthComponent


func _ready() -> void:
	collision_layer = HitRules.HURTBOX_LAYER
	collision_mask = 0
	monitoring = false
	monitorable = true


## Called by a Hitbox. Ignored once the owner is dead.
func receive_hit(info: HitInfo) -> void:
	if health != null:
		if health.is_dead():
			return
		health.apply_damage(info.damage)
	hit_received.emit(info)
