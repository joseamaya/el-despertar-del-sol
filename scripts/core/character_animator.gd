class_name CharacterAnimator
extends Node
## Drives a character's AnimationTree from its ground speed (idle, walk, jog, sprint),
## plus one-shot actions (attacks, roll) and the guard pose. Works for the player and for
## enemies: it only reads the injected body's velocity.

const PARAM_BLEND: StringName = &"parameters/locomotion/blend_position"
const PARAM_TIME_SCALE: StringName = &"parameters/time_scale/scale"
const PARAM_ATTACK_REQUEST: StringName = &"parameters/attack/request"
const PARAM_ATTACK_SPEED: StringName = &"parameters/attack_speed/scale"
const NODE_ATTACK_CLIP: StringName = &"attack_clip"
const PARAM_GUARD_BLEND: StringName = &"parameters/guard/blend_amount"
const GUARD_SHARPNESS: float = 18.0

@export var tuning: PlayerAnimationTuning
@export var body: CharacterBody3D
@export var animation_tree: AnimationTree

var _blend: float = 0.0
var _guard_target: float = 0.0
var _guard: float = 0.0


func _ready() -> void:
	assert(tuning != null, "CharacterAnimator needs a PlayerAnimationTuning resource.")
	assert(body != null and animation_tree != null, "CharacterAnimator needs body and tree.")
	animation_tree.active = true


func _physics_process(delta: float) -> void:
	tick(delta)


## Updates blend and playback rate from the player's current speed.
func tick(delta: float) -> void:
	var speed: float = Vector2(body.velocity.x, body.velocity.z).length()
	var target: float = LocomotionAnimMath.blend_position(speed, tuning)
	_blend = LocomotionAnimMath.smooth(_blend, target, tuning.blend_sharpness, delta)
	animation_tree.set(PARAM_BLEND, _blend)
	animation_tree.set(PARAM_TIME_SCALE, LocomotionAnimMath.time_scale(speed, tuning))
	_guard = LocomotionAnimMath.smooth(_guard, _guard_target, GUARD_SHARPNESS, delta)
	animation_tree.set(PARAM_GUARD_BLEND, _guard)


## Plays `clip` once so that it lasts `duration` seconds (e.g. the dodge roll).
func play_oneshot_timed(clip: StringName, duration: float) -> void:
	var length: float = animation_tree.get_animation(clip).length
	play_attack(clip, length / maxf(duration, 0.01))


## Blends the guard pose over the locomotion while blocking.
func set_guard(on: bool) -> void:
	_guard_target = 1.0 if on else 0.0


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
