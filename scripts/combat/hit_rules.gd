class_name HitRules
extends RefCounted
## Pure hit rules: factions and the sweep that keeps fast weapons from tunneling.

enum Faction { PLAYER, CHANCA, NEUTRAL }

const HURTBOX_LAYER: int = 1 << 3
const MAX_SWEEP_POINTS: int = 32


## No friendly fire. NEUTRAL can hit and be hit by everyone.
static func can_hit(attacker: Faction, target: Faction) -> bool:
	return attacker == Faction.NEUTRAL or target == Faction.NEUTRAL or attacker != target


## Points from `from` (exclusive) to `to` (inclusive), at most `step` apart, so a shape
## tested at every point covers the whole path even at high speed. Always includes `to`.
static func sweep_points(from: Vector3, to: Vector3, step: float) -> PackedVector3Array:
	var points := PackedVector3Array()
	var distance: float = from.distance_to(to)
	var count: int = clampi(ceili(distance / maxf(step, 0.001)), 1, MAX_SWEEP_POINTS)
	for i: int in count:
		points.append(from.lerp(to, float(i + 1) / count))
	return points
