class_name EncounterDirector
extends Node
## Hands out attack tokens (GDD §7.1: at most two attackers at once) and spreads enemies
## around their target. Lives in the level; enemies get it injected and register.

signal token_granted(enemy: Node3D)
signal token_released(enemy: Node3D)

@export var tuning: EncounterTuning

var _members: Array[Node3D] = []
var _holders: Array[Node3D] = []
var _since_grant: float = INF


func _ready() -> void:
	assert(tuning != null, "EncounterDirector needs an EncounterTuning resource.")


func _physics_process(delta: float) -> void:
	tick(delta)


## Advances the grant spacing timer. Public so tests can drive time.
func tick(delta: float) -> void:
	_since_grant += delta
	_prune()


func register(enemy: Node3D) -> void:
	if _members.has(enemy):
		return
	_members.append(enemy)
	enemy.tree_exiting.connect(_on_member_exiting.bind(enemy))


## Grants a token if one is free and the last grant was long enough ago. Holding one
## already counts as granted.
func request_token(enemy: Node3D) -> bool:
	_prune()
	if _holders.has(enemy):
		return true
	if _holders.size() >= tuning.max_attackers or _since_grant < tuning.grant_spacing:
		return false
	_holders.append(enemy)
	_since_grant = 0.0
	token_granted.emit(enemy)
	return true


func release_token(enemy: Node3D) -> void:
	if _holders.has(enemy):
		_holders.erase(enemy)
		token_released.emit(enemy)


func has_token(enemy: Node3D) -> bool:
	return _holders.has(enemy)


func token_count() -> int:
	_prune()
	return _holders.size()


## Push (flat, up to `separation_strength`) away from members closer than
## `separation_distance`, stronger the closer they are.
func separation(enemy: Node3D) -> Vector3:
	var push := Vector3.ZERO
	for other: Node3D in _members:
		if other == enemy or not is_instance_valid(other):
			continue
		var away := enemy.global_position - other.global_position
		away.y = 0.0
		var distance: float = away.length()
		if distance >= tuning.separation_distance:
			continue
		if distance < 0.001:
			away = Vector3.RIGHT
			distance = 0.001
		push += away.normalized() * (1.0 - distance / tuning.separation_distance)
	return push.limit_length(1.0) * tuning.separation_strength


func _prune() -> void:
	for holder: Node3D in _holders.duplicate():
		if not is_instance_valid(holder) or not holder.is_inside_tree():
			_holders.erase(holder)


func _on_member_exiting(enemy: Node3D) -> void:
	_members.erase(enemy)
	release_token(enemy)
