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
const NODE_ATTACK: StringName = &"attack"
## A held clip freezes this long before its fade-out would start.
const HOLD_MARGIN: float = 0.05
const PARAM_GUARD_BLEND: StringName = &"parameters/guard/blend_amount"
const GUARD_SHARPNESS: float = 18.0

@export var tuning: PlayerAnimationTuning
@export var body: CharacterBody3D
@export var animation_tree: AnimationTree

var _blend: float = 0.0
var _guard_target: float = 0.0
var _guard: float = 0.0
## Seconds until a held clip freezes (< 0: nothing to freeze).
var _hold_left: float = -1.0
var _held: bool = false


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
	if _hold_left >= 0.0:
		_hold_left -= delta
		if _hold_left <= 0.0:
			_hold_left = -1.0
			_held = true
			animation_tree.set(PARAM_ATTACK_SPEED, 0.0)


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
	_hold_left = -1.0
	_held = false
	animation_tree.set(PARAM_ATTACK_SPEED, speed)
	animation_tree.set(PARAM_ATTACK_REQUEST, AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)


## Plays `clip` once and stays on its last pose until stop_attack() (the player's fall:
## the body stays down until the retry instead of standing up again).
func play_and_hold(clip: StringName, speed: float) -> void:
	play_attack(clip, speed)
	var tree_root: AnimationNodeBlendTree = animation_tree.tree_root as AnimationNodeBlendTree
	var shot: AnimationNodeOneShot = tree_root.get_node(NODE_ATTACK) as AnimationNodeOneShot
	var length: float = animation_tree.get_animation(clip).length
	var speed_safe: float = maxf(speed, 0.01)
	_hold_left = maxf(0.0, (length - shot.fadeout_time) / speed_safe - HOLD_MARGIN)


## Whether a clip played with play_and_hold() is frozen on its last pose.
func is_holding() -> bool:
	return _held


func stop_attack() -> void:
	_hold_left = -1.0
	_held = false
	animation_tree.set(PARAM_ATTACK_REQUEST, AnimationNodeOneShot.ONE_SHOT_REQUEST_FADE_OUT)


func is_attack_playing() -> bool:
	return animation_tree.get(&"parameters/attack/active")


func get_blend() -> float:
	return _blend
