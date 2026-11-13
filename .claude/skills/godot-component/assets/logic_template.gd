class_name ExampleMath
extends RefCounted
## Pure rules for Example, no node access, so they can be unit tested.


## Value after `delta` seconds, never above `max_value`.
## Only the part of `delta` past `regen_delay` regenerates, so the frame that crosses
## the delay is frame-rate independent too. `idle_time` already includes this `delta`.
static func regenerate(
	current: float, idle_time: float, delta: float, tuning: ExampleTuning
) -> float:
	var regen_time: float = clampf(idle_time - tuning.regen_delay, 0.0, maxf(delta, 0.0))
	return minf(current + tuning.regen_per_second * regen_time, tuning.max_value)


## Optional spend (attack, dodge): all or nothing.
static func can_spend(current: float, cost: float) -> bool:
	return cost <= current


## Mandatory drain (a blocked hit always costs): never below zero.
static func drain(current: float, cost: float) -> float:
	return maxf(current - cost, 0.0)
