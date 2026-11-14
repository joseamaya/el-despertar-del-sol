class_name DefenseTuning
extends Resource
## Block, parry and dodge values (GDD §6.1, §6.5; DECISIONS/0007).

@export_group("Bloqueo")
## Stamina per blocked hit (GDD §6.5). If not covered, the guard breaks.
@export_range(0.0, 100.0, 0.5) var block_stamina_per_hit: float = 15.0
## Total frontal arc the block covers. Hits from outside it get through.
@export_range(10.0, 360.0, 1.0, "suffix:°") var block_arc_deg: float = 120.0
## Max move speed while blocking.
@export_range(0.0, 10.0, 0.1, "suffix:m/s") var block_move_speed: float = 2.0
## Stun after a broken guard: no actions, vulnerable.
@export_range(0.0, 3.0, 0.05, "suffix:s") var guard_break_stun: float = 0.8

@export_group("Parry")
## A block pressed this recently turns a frontal hit into a parry (GDD §6.5: 0.15 s).
@export_range(0.0, 1.0, 0.01, "suffix:s") var parry_window: float = 0.15
## Posture damage a parry sends back to the attacker (GDD §6.5: 2–3 parries break a
## basic warrior).
@export_range(0.0, 500.0, 1.0) var parry_posture_damage: float = 40.0

@export_group("Esquiva")
## Needs the whole cost (0007; GDD §6.5: 20).
@export_range(0.0, 100.0, 0.5) var dodge_stamina_cost: float = 20.0
## Invulnerability from the start of the dodge (GDD §6.5: 0.25 s).
@export_range(0.0, 1.0, 0.01, "suffix:s") var dodge_iframes: float = 0.25
@export_range(0.0, 10.0, 0.1, "suffix:m") var dodge_distance: float = 3.0
@export_range(0.1, 2.0, 0.05, "suffix:s") var dodge_duration: float = 0.65
@export var dodge_clip: StringName = &"Roll"
## Pose shown while blocking (free pack has no block clip: DECISIONS/0007).
@export var guard_clip: StringName = &"Sword_Idle"
