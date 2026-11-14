class_name DefenseRules
extends RefCounted
## Pure rules deciding what an incoming hit does to a defender.

enum Outcome { HIT, BLOCKED, PARRIED, EVADED, GUARD_BROKEN }


## Whether something at `to_attacker` (flat direction from defender to attacker) lies inside
## the frontal arc of a defender facing `facing`.
static func is_frontal(facing: Vector3, to_attacker: Vector3, arc_deg: float) -> bool:
	var f := Vector3(facing.x, 0.0, facing.z)
	var a := Vector3(to_attacker.x, 0.0, to_attacker.z)
	if f.length_squared() < 0.0001 or a.length_squared() < 0.0001:
		return true
	return f.angle_to(a) <= deg_to_rad(arc_deg) * 0.5


## Outcome of a hit. `since_block_press` is the time since block was last pressed.
static func resolve(
	evading: bool,
	blocking: bool,
	since_block_press: float,
	frontal: bool,
	stamina_covers_block: bool,
	tuning: DefenseTuning
) -> Outcome:
	if evading:
		return Outcome.EVADED
	if not blocking or not frontal:
		return Outcome.HIT
	if since_block_press <= tuning.parry_window:
		return Outcome.PARRIED
	return Outcome.BLOCKED if stamina_covers_block else Outcome.GUARD_BROKEN
