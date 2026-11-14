class_name CombatComponent
extends Node
## Player attacks: a chain of light attacks and a heavy one (GDD §6.2–6.3). Spends
## stamina, plays the clip through the animator, turns the weapon hitbox on only in the
## active phase and locks movement to the attack's lunge.

signal attack_started(data: AttackData)
signal attack_finished

enum Kind { NONE, LIGHT, HEAVY }

const ACTION_LIGHT: StringName = &"attack_light"
const ACTION_HEAVY: StringName = &"attack_heavy"

@export var light_chain: Array[AttackData] = []
@export var heavy: AttackData
@export var player: PlayerController
@export var stamina: StaminaComponent
@export var hitbox: Hitbox
## Optional: plays the attack clips. Without it attacks still work (tests).
@export var animator: PlayerAnimator

var _current: AttackData
var _elapsed: float = 0.0
var _chain_index: int = -1
var _buffered: Kind = Kind.NONE
var _phase: AttackRules.Phase = AttackRules.Phase.DONE


func _ready() -> void:
	assert(not light_chain.is_empty() and heavy != null, "CombatComponent needs its attacks.")
	assert(player != null and hitbox != null, "CombatComponent needs player and hitbox.")


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed(ACTION_LIGHT):
		request(Kind.LIGHT)
	elif Input.is_action_just_pressed(ACTION_HEAVY):
		request(Kind.HEAVY)
	tick(delta)


## Asks for an attack. Starts it now if idle, or buffers it for the chain.
func request(kind: Kind) -> void:
	if kind == Kind.NONE:
		return
	if _current == null:
		if player.is_in_action():
			return  # dodging or stunned
		_start(kind)
	elif AttackRules.accepts_buffer(_elapsed, _current):
		_buffered = kind


## Advances the attack timeline. Public so tests can drive time.
func tick(delta: float) -> void:
	if _current == null:
		return
	_elapsed += delta
	_update_phase()
	if _current == null:
		return
	player.set_action_velocity(
		player.get_action_forward() * AttackRules.lunge_speed(_elapsed, _current)
	)
	if _buffered != Kind.NONE and AttackRules.can_chain(_elapsed, _current):
		var kind: Kind = _buffered
		_buffered = Kind.NONE
		hitbox.deactivate()
		_start(kind)
	elif _phase == AttackRules.Phase.DONE:
		_finish()


## Stops the current attack at once (e.g. a dodge cancelling the recovery).
func cancel() -> void:
	if _current != null:
		_finish()


func is_attacking() -> bool:
	return _current != null


func get_current() -> AttackData:
	return _current


func get_phase() -> AttackRules.Phase:
	return _phase


func get_chain_index() -> int:
	return _chain_index


func _start(kind: Kind) -> void:
	var data: AttackData = _next_attack(kind)
	if stamina != null and not stamina.try_spend_partial(data.stamina_cost):
		_finish()
		return
	if kind == Kind.LIGHT:
		_chain_index = AttackRules.next_in_chain(_chain_index, light_chain.size())
	else:
		_chain_index = -1
	_current = data
	_elapsed = 0.0
	_phase = AttackRules.Phase.WINDUP
	player.begin_action()
	if animator != null:
		animator.play_attack(data.clip, data.clip_speed)
	attack_started.emit(data)


func _next_attack(kind: Kind) -> AttackData:
	if kind == Kind.HEAVY:
		return heavy
	return light_chain[AttackRules.next_in_chain(_chain_index, light_chain.size())]


func _update_phase() -> void:
	var next: AttackRules.Phase = AttackRules.phase(_elapsed, _current)
	if next == _phase:
		return
	_phase = next
	if _phase == AttackRules.Phase.ACTIVE:
		var owner_3d: Node3D = player
		hitbox.activate(HitInfo.create(_current.damage, _current.posture_damage, owner_3d))
	elif _phase == AttackRules.Phase.RECOVERY or _phase == AttackRules.Phase.DONE:
		hitbox.deactivate()


func _finish() -> void:
	hitbox.deactivate()
	var was_attacking: bool = _current != null
	_current = null
	_buffered = Kind.NONE
	_chain_index = -1
	_phase = AttackRules.Phase.DONE
	player.end_action()
	if animator != null:
		animator.stop_attack()
	if was_attacking:
		attack_finished.emit()
