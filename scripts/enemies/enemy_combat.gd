class_name EnemyCombat
extends Node
## Runs an enemy's attacks on the same timeline as the player's (AttackRules): telegraph
## during the windup, hitbox only in the active phase, lunge, and a cooldown afterwards.
## Its hits carry the enemy's posture so a parry can punish it.

signal attack_started(data: AttackData)
signal attack_finished

@export var data: EnemyData
@export var enemy: EnemyController
@export var hitbox: Hitbox
@export var posture: PostureComponent
## Visible only while winding up (GDD §12.4: visible attack indicators).
@export var telegraphs: Array[Node3D] = []
@export var animator: CharacterAnimator

var _current: AttackData
var _elapsed: float = 0.0
var _phase: AttackRules.Phase = AttackRules.Phase.DONE
var _cooldown_left: float = 0.0
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	assert(data != null and enemy != null and hitbox != null, "EnemyCombat needs its parts.")
	assert(not data.attacks.is_empty(), "EnemyData needs at least one attack.")
	_show_telegraph(false)
	_cooldown_left = _next_cooldown()


func _physics_process(delta: float) -> void:
	tick(delta)


## Advances cooldown and the current attack. Public so tests can drive time.
func tick(delta: float) -> void:
	if _current == null:
		_cooldown_left = maxf(0.0, _cooldown_left - delta)
		return
	_elapsed += delta
	var next: AttackRules.Phase = AttackRules.phase(_elapsed, _current)
	if next != _phase:
		_phase = next
		_on_phase_entered()
	if _current == null:
		return
	var lunge: float = AttackRules.lunge_speed(_elapsed, _current)
	if enemy.perception.has_target():
		var gap: float = enemy.distance_to(enemy.perception.last_known_position)
		if gap <= data.attack_contact_distance:
			lunge = 0.0
	enemy.push_forward(lunge)
	if _phase == AttackRules.Phase.DONE:
		_finish()


func is_ready() -> bool:
	return _current == null and _cooldown_left <= 0.0


func is_attacking() -> bool:
	return _current != null


func get_phase() -> AttackRules.Phase:
	return _phase


func get_current() -> AttackData:
	return _current


## Starts an attack (random one if none given).
func start(attack: AttackData = null) -> void:
	_current = attack if attack != null else data.attacks[_rng.randi() % data.attacks.size()]
	_elapsed = 0.0
	_phase = AttackRules.Phase.WINDUP
	_show_telegraph(true)
	if animator != null:
		animator.play_attack(_current.clip, _current.clip_speed)
	attack_started.emit(_current)


## Stops at once (stagger, death). Still goes on cooldown.
func cancel() -> void:
	if _current != null:
		_finish()


func set_cooldown(seconds: float) -> void:
	_cooldown_left = seconds


## Reseeds the attack and cooldown rolls. Re-rolls a pending cooldown so the whole
## sequence depends on the seed, not on the roll made in _ready().
func seed_rng(value: int) -> void:
	_rng.seed = value
	if _current == null:
		_cooldown_left = _next_cooldown()


func _on_phase_entered() -> void:
	match _phase:
		AttackRules.Phase.ACTIVE:
			_show_telegraph(false)
			var info := HitInfo.create(_current.damage, _current.posture_damage, enemy)
			info.source_posture = posture
			hitbox.activate(info)
		AttackRules.Phase.RECOVERY, AttackRules.Phase.DONE:
			hitbox.deactivate()


func _finish() -> void:
	hitbox.deactivate()
	_show_telegraph(false)
	_current = null
	_phase = AttackRules.Phase.DONE
	_cooldown_left = _next_cooldown()
	enemy.stop()
	attack_finished.emit()


func _next_cooldown() -> float:
	return _rng.randf_range(data.attack_cooldown_min, data.attack_cooldown_max)


func _show_telegraph(on: bool) -> void:
	for node: Node3D in telegraphs:
		node.visible = on


func is_telegraphing() -> bool:
	return not telegraphs.is_empty() and telegraphs[0].visible
