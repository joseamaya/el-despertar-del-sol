class_name PlayerAnimator
extends Node
## Drives the player's AnimationTree from its ground speed (idle, walk, jog, sprint).
## Reads the injected PlayerController; knows nothing about input or the camera.

const PARAM_BLEND: StringName = &"parameters/locomotion/blend_position"
const PARAM_TIME_SCALE: StringName = &"parameters/time_scale/scale"

@export var tuning: PlayerAnimationTuning
@export var player: PlayerController
@export var animation_tree: AnimationTree

var _blend: float = 0.0


func _ready() -> void:
	assert(tuning != null, "PlayerAnimator needs a PlayerAnimationTuning resource.")
	assert(player != null and animation_tree != null, "PlayerAnimator needs player and tree.")
	animation_tree.active = true


func _physics_process(delta: float) -> void:
	tick(delta)


## Updates blend and playback rate from the player's current speed.
func tick(delta: float) -> void:
	var speed: float = player.get_horizontal_speed()
	var target: float = LocomotionAnimMath.blend_position(speed, tuning)
	_blend = LocomotionAnimMath.smooth(_blend, target, tuning.blend_sharpness, delta)
	animation_tree.set(PARAM_BLEND, _blend)
	animation_tree.set(PARAM_TIME_SCALE, LocomotionAnimMath.time_scale(speed, tuning))


func get_blend() -> float:
	return _blend
