extends GdUnitTestSuite
## The chanca lancer (F9 tasks 9 and 10, `DECISIONS/0017`): its data within GDD §6.5, the
## thrust hitting from beyond the club's reach, a held block stopping it, and keeping its
## distance when Cusi comes close.

const TEST_SCENE: String = "res://scenes/tests/enemy_test.tscn"
const LANCER: String = "res://scenes/enemies/chanca_lancer.tscn"
const WARRIOR: String = "res://scenes/enemies/chanca_warrior.tscn"
const LANCER_DATA: String = "res://resources/enemies/lancero_chanca.tres"
const WARRIOR_DATA: String = "res://resources/enemies/guerrero_chanca.tres"
## Between the lancer and Cusi: beyond the club, within the spear.
const GAP: float = 3.0
## Cusi right on top of the enemy (inside the lancer's keep-away distance).
const CLOSE: float = 1.2

var _runner: GdUnitSceneRunner
var _player: PlayerController
var _health: HealthComponent
var _defense: DefenseComponent
var _blocked: int = 0


func before_test() -> void:
	_blocked = 0
	_runner = scene_runner(TEST_SCENE)
	_player = _runner.find_child("Player") as PlayerController
	_health = _player.get_node("Health") as HealthComponent
	_defense = _player.get_node("Defense") as DefenseComponent
	_defense.blocked.connect(func(_i: HitInfo) -> void: _blocked += 1)
	for warrior: String in ["Warrior1", "Warrior2", "Warrior3"]:
		(_runner.find_child(warrior) as Node).process_mode = Node.PROCESS_MODE_DISABLED
	_player.global_position = Vector3(0, 0.05, 6)
	_player.rotation.y = 0.0
	_player.velocity = Vector3.ZERO
	await _frames(5)


func after_test() -> void:
	Input.action_release(&"block")
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _frames(count: int) -> void:
	for i: int in count:
		await get_tree().physics_frame


## An enemy `GAP` m in front of Cusi, facing him, that only attacks when told.
func _enemy_in_front(scene: String, gap: float = GAP, thinking: bool = false) -> EnemyController:
	var enemy := (load(scene) as PackedScene).instantiate() as EnemyController
	enemy.director = null
	enemy.position = _player.global_position + Vector3(0, 0, -gap)
	enemy.rotation.y = PI
	_runner.scene().add_child(enemy)
	enemy.perception.target = _player
	if not thinking:
		enemy.state_machine.process_mode = Node.PROCESS_MODE_DISABLED
	await _frames(3)
	return enemy


func _gap(enemy: EnemyController) -> float:
	return enemy.distance_to(_player.global_position)


## The gap when the swing starts, from the attack state with Cusi `CLOSE` in front.
func _gap_at_swing(scene: String) -> float:
	var enemy: EnemyController = await _enemy_in_front(scene, CLOSE, true)
	enemy.combat.set_cooldown(0.0)
	enemy.state_machine.transition_to(&"attack")
	for i: int in 120:
		if enemy.combat.is_attacking():
			break
		await get_tree().physics_frame
	assert_bool(enemy.combat.is_attacking()).is_true()
	return _gap(enemy)


func _strike(enemy: EnemyController) -> void:
	enemy.combat.start(enemy.data.attacks[0])
	for i: int in 240:
		if not enemy.combat.is_attacking():
			return
		await get_tree().physics_frame


func test_data_within_the_initial_tuning() -> void:
	var lancer := load(LANCER_DATA) as EnemyData
	var warrior := load(WARRIOR_DATA) as EnemyData
	var thrust: AttackData = lancer.attacks[0]
	assert_bool(thrust.thrust).is_true()
	# GDD §6.5: a basic enemy telegraphs 0.6–0.8 s.
	assert_float(AttackRules.real(thrust.windup_end, thrust)).is_between(0.6, 0.8)
	# Longer reach and longer preparation than the club; less posture damage.
	assert_float(lancer.attack_range).is_greater(warrior.attack_range)
	assert_float(lancer.engage_distance).is_greater(warrior.engage_distance)
	for club: AttackData in warrior.attacks:
		assert_float(thrust.posture_damage).is_less(club.posture_damage)
		var club_windup: float = AttackRules.real(club.windup_end, club)
		assert_float(AttackRules.real(thrust.windup_end, thrust)).is_greater(club_windup)


func test_the_hitbox_rides_on_the_spear_tip() -> void:
	var lancer: EnemyController = await _enemy_in_front(LANCER)
	var tip: Node3D = lancer.find_children("Tip", "Marker3D", true, false)[0]
	assert_object(lancer.combat.hitbox.get_parent()).is_same(tip)
	assert_bool(lancer.combat.telegraphs.size() >= 2).is_true()


func test_the_thrust_hits_beyond_the_club() -> void:
	var warrior: EnemyController = await _enemy_in_front(WARRIOR)
	await _strike(warrior)
	assert_float(_health.current).is_equal(_health.get_maximum())
	warrior.queue_free()
	await _frames(2)
	var lancer: EnemyController = await _enemy_in_front(LANCER)
	await _strike(lancer)
	assert_float(_health.current).is_less(_health.get_maximum())


func test_a_held_block_stops_the_thrust() -> void:
	Input.action_press(&"block")
	await _frames(5)
	var lancer: EnemyController = await _enemy_in_front(LANCER)
	await _strike(lancer)
	assert_float(_health.current).is_equal(_health.get_maximum())
	assert_int(_blocked).is_equal(1)


func test_too_close_while_circling_it_backs_off() -> void:
	var lancer: EnemyController = await _enemy_in_front(LANCER, CLOSE, true)
	lancer.combat.set_cooldown(30.0)
	lancer.state_machine.transition_to(&"strafe")
	var states: Array[String] = []
	for i: int in 90:
		states.append(String(lancer.state_machine.current_name()))
		await get_tree().physics_frame
	assert_array(states).contains(["retreat"])
	assert_float(_gap(lancer)).is_greater(lancer.data.keep_away_distance)


func test_it_steps_back_before_the_thrust() -> void:
	var gap: float = await _gap_at_swing(LANCER)
	var keep: float = (load(LANCER_DATA) as EnemyData).keep_away_distance
	assert_float(gap).is_greater(keep - 0.2)


func test_the_club_strikes_from_where_it_is() -> void:
	assert_float((load(WARRIOR_DATA) as EnemyData).keep_away_distance).is_equal(0.0)
	var gap: float = await _gap_at_swing(WARRIOR)
	assert_float(gap).is_less(CLOSE + 0.3)
