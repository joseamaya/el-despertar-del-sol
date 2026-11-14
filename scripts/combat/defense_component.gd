class_name DefenseComponent
extends Node
## Block (hold), parry (block pressed just in time) and dodge with invulnerability
## (GDD §6.1–6.5). The Hurtbox asks resolve_hit() before applying damage.

signal blocked(info: HitInfo)
signal parried(info: HitInfo)
signal evaded(info: HitInfo)
signal guard_broken
signal dodge_started

const ACTION_BLOCK: StringName = &"block"
const ACTION_DODGE: StringName = &"dodge"

@export var tuning: DefenseTuning
@export var player: PlayerController
@export var stamina: StaminaComponent
## Optional: attacks suspend the block; dodge cancels an attack's recovery.
@export var combat: CombatComponent
@export var animator: PlayerAnimator

var _block_held: bool = false
var _since_block_press: float = INF
var _dodging: bool = false
var _dodge_elapsed: float = 0.0
var _dodge_direction: Vector3 = Vector3.ZERO
var _stun_left: float = 0.0


func _ready() -> void:
	assert(tuning != null and player != null, "DefenseComponent needs tuning and player.")


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed(ACTION_BLOCK):
		press_block()
	set_block_held(Input.is_action_pressed(ACTION_BLOCK))
	if Input.is_action_just_pressed(ACTION_DODGE):
		request_dodge()
	tick(delta)


## A fresh block press starts the parry window.
func press_block() -> void:
	_since_block_press = 0.0
	_block_held = true


func set_block_held(held: bool) -> void:
	_block_held = held


## Advances dodge, stun, parry window and block posture. Public so tests can drive time.
func tick(delta: float) -> void:
	_since_block_press += delta
	if _stun_left > 0.0:
		_stun_left -= delta
		if _stun_left <= 0.0:
			player.end_action()
	if _dodging:
		_dodge_elapsed += delta
		player.set_action_velocity(_dodge_direction * tuning.dodge_distance / tuning.dodge_duration)
		if _dodge_elapsed >= tuning.dodge_duration:
			_dodging = false
			player.end_action()
	var guarding: bool = is_blocking()
	player.set_speed_limit(tuning.block_move_speed if guarding else -1.0)
	if animator != null:
		animator.set_guard(guarding)


## Dodge toward the stick (camera-relative), or backwards without input. Needs the whole
## stamina cost; cancels an attack only in its recovery. Returns true if it started.
func request_dodge(direction: Vector3 = Vector3.ZERO) -> bool:
	if _dodging or is_stunned():
		return false
	if combat != null and combat.is_attacking():
		if combat.get_phase() != AttackRules.Phase.RECOVERY:
			return false
	if stamina != null and not stamina.try_spend_full(tuning.dodge_stamina_cost):
		return false
	if combat != null and combat.is_attacking():
		combat.cancel()
	var dir: Vector3 = direction if not direction.is_zero_approx() else player.get_move_direction()
	if dir.is_zero_approx():
		dir = -player.get_action_forward()
	_dodge_direction = Vector3(dir.x, 0.0, dir.z).normalized()
	_dodging = true
	_dodge_elapsed = 0.0
	player.begin_action(_dodge_direction, false)
	if animator != null:
		animator.play_oneshot_timed(tuning.dodge_clip, tuning.dodge_duration)
	dodge_started.emit()
	return true


## Called by the Hurtbox before damage. Applies stamina cost and stun as needed.
func resolve_hit(info: HitInfo) -> DefenseRules.Outcome:
	var to_attacker: Vector3 = _direction_to_attacker(info)
	var frontal: bool = DefenseRules.is_frontal(
		player.get_action_forward(), to_attacker, tuning.block_arc_deg
	)
	var covers: bool = (
		stamina == null
		or StaminaRules.can_spend_full(stamina.current, tuning.block_stamina_per_hit)
	)
	var outcome: DefenseRules.Outcome = DefenseRules.resolve(
		is_invulnerable(), is_blocking(), _since_block_press, frontal, covers, tuning
	)
	match outcome:
		DefenseRules.Outcome.EVADED:
			evaded.emit(info)
		DefenseRules.Outcome.PARRIED:
			parried.emit(info)
		DefenseRules.Outcome.BLOCKED:
			if stamina != null:
				stamina.drain(tuning.block_stamina_per_hit)
			blocked.emit(info)
		DefenseRules.Outcome.GUARD_BROKEN:
			if stamina != null:
				stamina.drain(tuning.block_stamina_per_hit)
			_break_guard()
	return outcome


func is_blocking() -> bool:
	if not _block_held or _dodging or is_stunned():
		return false
	return combat == null or not combat.is_attacking()


func is_dodging() -> bool:
	return _dodging


func is_invulnerable() -> bool:
	return _dodging and _dodge_elapsed <= tuning.dodge_iframes


func is_stunned() -> bool:
	return _stun_left > 0.0


func _break_guard() -> void:
	_block_held = false
	_stun_left = tuning.guard_break_stun
	player.begin_action(Vector3.ZERO, false)
	guard_broken.emit()


func _direction_to_attacker(info: HitInfo) -> Vector3:
	var origin: Vector3 = player.global_position
	if info.attacker != null and is_instance_valid(info.attacker):
		return info.attacker.global_position - origin
	if not info.direction.is_zero_approx():
		return -info.direction
	return info.point - origin
