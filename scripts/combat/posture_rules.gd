class_name PostureRules
extends RefCounted
## Pure posture rules.


## Value after `delta` seconds. Only the part of `delta` past `decay_delay` drains, so the
## frame that crosses the delay is frame-rate independent. `idle_time` includes `delta`.
static func decay(current: float, idle_time: float, delta: float, tuning: PostureTuning) -> float:
	var decay_time: float = clampf(idle_time - tuning.decay_delay, 0.0, maxf(delta, 0.0))
	return maxf(current - tuning.decay_per_second * decay_time, 0.0)


static func breaks(current: float, tuning: PostureTuning) -> bool:
	return current >= tuning.max_posture
