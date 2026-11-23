class_name CombatComponent
extends Node
## Player attacks: a chain of light attacks and a heavy one (GDD §6.2–6.3). Spends
## stamina, plays the clip through the animator, turns the weapon hitbox on only in the
## active phase and locks movement to the attack's lunge.

signal attack_started(data: AttackData)
signal attack_finished
signal executed(target: Hurtbox)

enum Kind { NONE, LIGHT, HEAVY }

const ACTION_LIGHT: StringName = &"attack_light"
const ACTION_HEAVY: StringName = &"attack_heavy"

@export var light_chain: Array[AttackData] = []
@export var heavy: AttackData
@export var player: PlayerController
@export var stamina: StaminaComponent
@export var hitbox: Hitbox
## Optional: plays the attack clips. Without it attacks still work (tests).
@export var animator: CharacterAnimator
## Optional: a light attack next to an enemy with broken posture executes it (GDD §6.4).
@export var execution: AttackData
## Optional: keeps an attack pressed during a dodge or a stun (F6 task 7).
@export var response: ResponseTuning

var _current: AttackData
var _elapsed: float = 0.0
var _chain_index: int = -1
var _buffered: Kind = Kind.NONE
var _phase: AttackRules.Phase = AttackRules.Phase.DONE
var _execution_target: Hurtbox
## An attack pressed while the player was busy, and how long it still waits.
var _waiting: Kind = Kind.NONE
var _wait_left: float = 0.0


func _ready() -> void:
	assert(not light_chain.is_empty() and heavy != null, "CombatComponent needs its attacks.")
	assert(player != null and hitbox != null, "CombatComponent needs player and hitbox.")


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed(ACTION_LIGHT):
		request(Kind.LIGHT)
	elif Input.is_action_just_pressed(ACTION_HEAVY):
		request(Kind.HEAVY)
	tick_waiting(delta)
	tick(delta)


## Asks for an attack. Starts it now if idle, or buffers it for the chain.
func request(kind: Kind) -> void:
	if kind == Kind.NONE:
		return
	if _current == null:
		if player.is_in_action():
			# Dodging or stunned: keep the press for a moment (F6 task 7).
			if response != null and response.attack_buffer > 0.0:
				_waiting = kind
				_wait_left = response.attack_buffer
			return
		if kind == Kind.LIGHT and execution != null:
			var target: Hurtbox = find_executable()
			if target != null:
				_start_execution(target)
				return
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
		var target: Hurtbox = find_executable() if kind == Kind.LIGHT else null
		if target != null:
			_start_execution(target)
		else:
			_start(kind)
	elif _phase == AttackRules.Phase.DONE:
		_finish()


## Starts a kept attack as soon as the player is free, or forgets it when it has waited
## too long. Public so tests can drive time.
func tick_waiting(delta: float) -> void:
	if _waiting == Kind.NONE:
		return
	if _current == null and not player.is_in_action():
		var kind: Kind = _waiting
		_waiting = Kind.NONE
		request(kind)
		return
	_wait_left -= delta
	if _wait_left <= 0.0:
		_waiting = Kind.NONE


## Whether an attack press is waiting to start.
func is_attack_waiting() -> bool:
	return _waiting != Kind.NONE


## Stops the current attack at once (e.g. a dodge cancelling the recovery).
func cancel() -> void:
	_waiting = Kind.NONE
	if _current != null:
		_finish()


func is_attacking() -> bool:
	return _current != null


func get_current() -> AttackData:
	return _current


func get_phase() -> AttackRules.Phase:
	return _phase


## Seconds since the current attack started (0 when idle).
func get_elapsed() -> float:
	return _elapsed if _current != null else 0.0


func get_chain_index() -> int:
	return _chain_index


## Closest enemy Hurtbox in front, within execution range, whose posture is broken.
func find_executable() -> Hurtbox:
	if execution == null:
		return null
	var shape := SphereShape3D.new()
	shape.radius = execution.execution_range
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = shape
	query.transform = Transform3D(Basis.IDENTITY, player.global_position + Vector3.UP * 0.9)
	query.collision_mask = HitRules.HURTBOX_LAYER
	query.collide_with_areas = true
	query.collide_with_bodies = false
	var best: Hurtbox = null
	var best_distance: float = INF
	for result: Dictionary in player.get_world_3d().direct_space_state.intersect_shape(query):
		var hurtbox: Hurtbox = result["collider"] as Hurtbox
		if hurtbox == null or not hurtbox.is_executable():
			continue
		if not HitRules.can_hit(hitbox.faction, hurtbox.faction):
			continue
		var to_target: Vector3 = hurtbox.global_position - player.global_position
		if not DefenseRules.is_frontal(
			player.get_action_forward(), to_target, execution.execution_arc_deg
		):
			continue
		var distance: float = Vector2(to_target.x, to_target.z).length()
		if distance < best_distance:
			best_distance = distance
			best = hurtbox
	return best


func _start_execution(target: Hurtbox) -> void:
	_current = execution
	_execution_target = target
	_elapsed = 0.0
	_chain_index = -1
	_phase = AttackRules.Phase.WINDUP
	player.begin_action(target.global_position - player.global_position, false)
	if animator != null:
		animator.play_attack(execution.clip, execution.clip_speed)
	attack_started.emit(execution)


func _deliver_execution() -> void:
	if _execution_target == null or not is_instance_valid(_execution_target):
		return
	var info := HitInfo.create(execution.damage, 0.0, player)
	info.unblockable = true
	info.point = _execution_target.global_position
	_execution_target.receive_hit(info)
	executed.emit(_execution_target)
	_execution_target = null


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
	if _phase == AttackRules.Phase.ACTIVE and _current == execution:
		_deliver_execution()
	elif _phase == AttackRules.Phase.ACTIVE:
		var owner_3d: Node3D = player
		hitbox.activate(HitInfo.create(_current.damage, _current.posture_damage, owner_3d))
	elif _phase == AttackRules.Phase.RECOVERY or _phase == AttackRules.Phase.DONE:
		hitbox.deactivate()


func _finish() -> void:
	hitbox.deactivate()
	var was_attacking: bool = _current != null
	_current = null
	_execution_target = null
	_buffered = Kind.NONE
	_chain_index = -1
	_phase = AttackRules.Phase.DONE
	player.end_action()
	if animator != null:
		animator.stop_attack()
	if was_attacking:
		attack_finished.emit()
