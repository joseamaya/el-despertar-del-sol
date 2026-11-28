class_name EscortRules
extends RefCounted
## Pure rules of an escort (F10 task 5): where each freed person walks behind the leader,
## when a Chanca goes for one of them, and when the party has arrived.


## The place of person `index` of `count` behind a leader at `leader` who looks along
## `forward` (flat): a row `distance` behind, `spacing` apart, centred.
static func follow_slot(
	leader: Vector3, forward: Vector3, index: int, count: int, distance: float, spacing: float
) -> Vector3:
	var ahead := Vector3(forward.x, 0.0, forward.z)
	if ahead.length_squared() < 0.0001:
		ahead = Vector3.FORWARD
	ahead = ahead.normalized()
	var side: Vector3 = ahead.cross(Vector3.UP)
	var offset: float = (float(index) - float(count - 1) * 0.5) * spacing
	return leader - ahead * distance + side * offset


## Whether a Chanca at `enemy` goes for the person at `person`: Cusi, at `leader`, is
## farther than `protect` from them and the Chanca is within `threat` of them.
static func threatens(
	leader: Vector3, person: Vector3, enemy: Vector3, protect: float, threat: float
) -> bool:
	return _flat(leader, person) > protect and _flat(enemy, person) <= threat


## Whether every one of `points` is within `radius` of `centre` (flat).
static func all_within(points: PackedVector3Array, centre: Vector3, radius: float) -> bool:
	for p: Vector3 in points:
		if _flat(p, centre) > radius:
			return false
	return true


static func _flat(a: Vector3, b: Vector3) -> float:
	return Vector2(a.x - b.x, a.z - b.z).length()
