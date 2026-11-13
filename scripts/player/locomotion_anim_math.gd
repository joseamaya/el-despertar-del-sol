class_name LocomotionAnimMath
extends RefCounted
## Pure helpers mapping ground speed to locomotion blend and playback rate.
## The blend space places each clip at its natural cycle speed, so blending at the
## actual speed keeps the feet planted between walk, jog and sprint.


## Blend position for the speed-based BlendSpace1D: the speed itself, clamped to the
## range the clips cover.
static func blend_position(speed: float, tuning: PlayerAnimationTuning) -> float:
	return clampf(speed, 0.0, tuning.sprint_cycle_speed)


## Playback rate: 1 inside the clips' range, faster above the sprint cycle (capped).
static func time_scale(speed: float, tuning: PlayerAnimationTuning) -> float:
	if speed <= tuning.sprint_cycle_speed:
		return 1.0
	return minf(speed / tuning.sprint_cycle_speed, tuning.max_time_scale)


## Frame-rate independent exponential approach of `current` toward `target`.
static func smooth(current: float, target: float, sharpness: float, delta: float) -> float:
	return lerpf(current, target, 1.0 - exp(-sharpness * delta))
