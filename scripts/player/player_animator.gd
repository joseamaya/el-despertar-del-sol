class_name PlayerAnimator
extends Node
## Drives the player's AnimationTree from its ground speed (idle, walk, jog, sprint).
## Reads the injected PlayerController; knows nothing about input or the camera.

const PARAM_BLEND: StringName = &"parameters/locomotion/blend_position"
const PARAM_TIME_SCALE: StringName = &"parameters/time_scale/scale"
const PARAM_ATTACK_REQUEST: StringName = &"parameters/attack/request"
const PARAM_ATTACK_SPEED: StringName = &"parameters/attack_speed/scale"
const NODE_ATTACK_CLIP: StringName = &"attack_clip"

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


## Plays an attack clip once over the locomotion (OneShot), at `speed`.
func play_attack(clip: StringName, speed: float) -> void:
	var tree_root: AnimationNodeBlendTree = animation_tree.tree_root as AnimationNodeBlendTree
	var node: AnimationNodeAnimation = (
		tree_root.get_node(NODE_ATTACK_CLIP) as AnimationNodeAnimation
	)
	node.animation = clip
	animation_tree.set(PARAM_ATTACK_SPEED, speed)
	animation_tree.set(PARAM_ATTACK_REQUEST, AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)


func stop_attack() -> void:
	animation_tree.set(PARAM_ATTACK_REQUEST, AnimationNodeOneShot.ONE_SHOT_REQUEST_FADE_OUT)


func is_attack_playing() -> bool:
	return animation_tree.get(&"parameters/attack/active")


func get_blend() -> float:
	return _blend
