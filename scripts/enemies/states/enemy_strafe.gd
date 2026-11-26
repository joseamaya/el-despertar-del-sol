class_name EnemyStrafe
extends State
## Circles the target at engage distance, facing it and switching direction now and then.
## Attacks from here when its cooldown is over and the director grants a token; without a
## token it may feint and keeps circling (GDD §6.6). A lancer backs off when the target
## comes inside its keep-away distance (F9 task 10), at most once per cooldown.

var _side: int = 1
var _switch_left: float = 0.0
var _back_off_left: float = 0.0
var _rng := RandomNumberGenerator.new()


func enter(previous: StringName) -> void:
	_side = 1 if _rng.randf() < 0.5 else -1
	_switch_left = _next_switch()
	if previous == &"retreat":
		_back_off_left = _enemy().data.keep_away_cooldown


func exit() -> void:
	_enemy().clear_face()


func seed_rng(value: int) -> void:
	_rng.seed = value


func physics_update(delta: float) -> StringName:
	var enemy: EnemyController = _enemy()
	if not enemy.perception.has_target():
		return &"idle"
	if not enemy.perception.can_sense():
		return &"chase"  # lost sight: go to where it was last seen
	var target: Vector3 = enemy.perception.last_known_position
	if enemy.distance_to(target) > enemy.data.engage_distance * 1.6:
		return &"chase"
	var next: StringName = _next_move(enemy, target, delta)
	if next != &"":
		return next
	_switch_left -= delta
	if _switch_left <= 0.0:
		_side = -_side
		_switch_left = _next_switch()
	enemy.face(target)
	enemy.strafe_around(target, enemy.data.engage_distance, _side, enemy.data.strafe_speed)
	return &""


## Whether `target` is inside the enemy's keep-away distance (the lancer; F9 task 10).
static func too_close(enemy: EnemyController, target: Vector3) -> bool:
	var keep: float = enemy.data.keep_away_distance
	return keep > 0.0 and enemy.distance_to(target) < keep


## Leaves the circle to back off (a lancer, too close), to attack or to feint; or stays.
func _next_move(enemy: EnemyController, target: Vector3, delta: float) -> StringName:
	_back_off_left = maxf(0.0, _back_off_left - delta)
	if _back_off_left <= 0.0 and too_close(enemy, target):
		return &"retreat"
	if enemy.combat == null or not enemy.combat.is_ready():
		return &""
	if enemy.director == null or enemy.director.request_token(enemy):
		return &"attack"
	enemy.combat.set_cooldown(enemy.data.token_retry)
	return &"feint" if _rng.randf() < enemy.data.feint_chance else &""


func _next_switch() -> float:
	var data: EnemyData = _enemy().data
	return _rng.randf_range(data.strafe_switch_min, data.strafe_switch_max)


func _enemy() -> EnemyController:
	return machine.context as EnemyController
