class_name AttackRules
extends RefCounted
## Pure attack timeline rules. Times in real seconds since the attack started.

enum Phase { WINDUP, ACTIVE, RECOVERY, DONE }

## Presses earlier than this before chain_from are dropped (no button mashing).
const BUFFER_WINDOW: float = 0.35


static func real(clip_seconds: float, data: AttackData) -> float:
	return clip_seconds / maxf(data.clip_speed, 0.001)


static func phase(elapsed: float, data: AttackData) -> Phase:
	if elapsed < real(data.windup_end, data):
		return Phase.WINDUP
	if elapsed < real(data.active_end, data):
		return Phase.ACTIVE
	if elapsed < real(data.recovery_end, data):
		return Phase.RECOVERY
	return Phase.DONE


## Whether a press at `elapsed` is kept for chaining.
static func accepts_buffer(elapsed: float, data: AttackData) -> bool:
	return elapsed >= real(data.chain_from, data) - BUFFER_WINDOW


## Whether a buffered press may start the next attack now.
static func can_chain(elapsed: float, data: AttackData) -> bool:
	return elapsed >= real(data.chain_from, data)


## Forward speed of the lunge during windup and active phases; 0 afterwards.
static func lunge_speed(elapsed: float, data: AttackData) -> float:
	var moving: float = real(data.active_end, data)
	if moving <= 0.0 or elapsed >= moving:
		return 0.0
	return data.lunge_distance / moving


## Index of the next light attack in a chain of `count`, wrapping to the first.
static func next_in_chain(index: int, count: int) -> int:
	return 0 if count <= 0 else (index + 1) % count
