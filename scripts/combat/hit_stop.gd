class_name HitStop
extends Node
## Briefly slows global time on impact. Connect Hitbox.hit_landed to on_hit_landed().
## Overlapping hits extend the stop instead of stacking: only the latest timer restores.

@export var tuning: CombatFeelTuning

var _stop_id: int = 0


func _ready() -> void:
	assert(tuning != null, "HitStop needs a CombatFeelTuning resource.")


func _exit_tree() -> void:
	Engine.time_scale = 1.0


func on_hit_landed(_hurtbox: Hurtbox, _info: HitInfo) -> void:
	trigger()


## Freezes for `duration` seconds (real time), or the tuned default if negative.
func trigger(duration: float = -1.0) -> void:
	var seconds: float = tuning.hitstop_duration if duration < 0.0 else duration
	if seconds <= 0.0:
		return
	_stop_id += 1
	Engine.time_scale = tuning.hitstop_time_scale
	var timer: SceneTreeTimer = get_tree().create_timer(seconds, true, false, true)
	timer.timeout.connect(_on_timeout.bind(_stop_id))


func is_stopped() -> bool:
	return Engine.time_scale < 1.0


func _on_timeout(id: int) -> void:
	if id == _stop_id:
		Engine.time_scale = 1.0
