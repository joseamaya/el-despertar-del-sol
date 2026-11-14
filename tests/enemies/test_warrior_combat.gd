extends GdUnitTestSuite
## Integration: the chanca warrior's attacks, guard and reactions in enemy_test.tscn.
## Warrior1 at (-8,0,-4) facing +Z; the player stands 1.6 m in front, facing it.

const TEST_SCENE: String = "res://scenes/tests/enemy_test.tscn"

var _runner: GdUnitSceneRunner
var _player: PlayerController
var _w: EnemyController
var _data: EnemyData


func before_test() -> void:
	_runner = scene_runner(TEST_SCENE)
	_player = _runner.find_child("Player") as PlayerController
	_w = _runner.find_child("Warrior1") as EnemyController
	(_runner.find_child("Warrior2") as Node).process_mode = Node.PROCESS_MODE_DISABLED
	(_runner.find_child("Warrior3") as Node).process_mode = Node.PROCESS_MODE_DISABLED
	_use_own_data()
	_player.global_position = Vector3(-8, 0.05, -2.4)
	_player.rotation.y = 0.0
	_player.velocity = Vector3.ZERO
	# Attack tests drive EnemyCombat directly: freeze the AI so it does not wander off.
	_w.state_machine.set_physics_process(false)
	_w.combat.set_cooldown(99.0)
	await _frames(3)


func after_test() -> void:
	Engine.time_scale = 1.0
	Input.action_release(&"block")
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _enable_ai() -> void:
	_w.state_machine.set_physics_process(true)


## Tests tweak values; give this warrior its own copy so other tests keep the shipped data.
func _use_own_data() -> void:
	_data = _w.data.duplicate() as EnemyData
	_w.data = _data
	_w.perception.data = _data
	_w.guard.data = _data
	_w.combat.data = _data


func _frames(count: int) -> void:
	for i: int in count:
		await get_tree().physics_frame


func _state() -> String:
	return String(_w.state_machine.current_name())


func _attack(id: String) -> AttackData:
	return load("res://resources/combat/attacks/enemy/%s.tres" % id) as AttackData


func _until_attack_done() -> void:
	for i: int in 240:
		if not _w.combat.is_attacking():
			return
		await get_tree().physics_frame


func _player_health() -> HealthComponent:
	return _player.get_node("Health") as HealthComponent


func _hit_enemy(posture_damage: float) -> void:
	var hurt := _w.get_node("Hurtbox") as Hurtbox
	hurt.receive_hit(HitInfo.create(10.0, posture_damage, _player))


func test_wiring() -> void:
	assert_int(_w.data.attacks.size()).is_equal(2)
	assert_object((_w.get_node("Hurtbox") as Hurtbox).defense).is_same(_w.guard)
	assert_int(_w.combat.hitbox.faction).is_equal(HitRules.Faction.CHANCA)
	assert_int(_w.combat.telegraphs.size()).is_equal(2)


func test_telegraph_only_in_windup_and_lasts_06_to_08_s() -> void:
	_w.combat.start(_attack("chanca_golpe"))
	var visible_frames: int = 0
	for i: int in 150:
		await get_tree().physics_frame
		if not _w.combat.is_attacking():
			break
		var winding: bool = _w.combat.get_phase() == AttackRules.Phase.WINDUP
		assert_bool(_w.combat.is_telegraphing()).is_equal(winding)
		assert_bool(_w.combat.hitbox.is_active()).is_equal(
			_w.combat.get_phase() == AttackRules.Phase.ACTIVE
		)
		if winding:
			visible_frames += 1
	assert_int(visible_frames).is_between(35, 49)


func test_undefended_player_takes_the_hit() -> void:
	_w.combat.start(_attack("chanca_golpe"))
	await _until_attack_done()
	assert_float(_player_health().current).is_equal(_player_health().get_maximum() - 14.0)


func test_player_block_stops_it() -> void:
	Input.action_press(&"block")
	await _frames(12)
	_w.combat.start(_attack("chanca_golpe"))
	await _until_attack_done()
	assert_float(_player_health().current).is_equal(_player_health().get_maximum())


func _parried_attack() -> void:
	var defense := _player.get_node("Defense") as DefenseComponent
	_w.global_position = Vector3(-8, 0.05, -4)
	Input.action_press(&"block")
	_w.combat.start(_attack("chanca_golpe"))
	for i: int in 240:
		defense.press_block()  # keeps the parry window open: every contact is a parry
		await get_tree().physics_frame
		if not _w.combat.is_attacking():
			break


func test_parry_hurts_the_attackers_posture() -> void:
	await _parried_attack()
	assert_float(_player_health().current).is_equal(_player_health().get_maximum())
	assert_float(_w.posture.current).is_greater_equal(38.0)


func test_three_parries_break_its_posture() -> void:
	for i: int in 3:
		await _parried_attack()
	assert_bool(_w.posture.is_broken()).is_true()
	await _frames(2)
	assert_str(_state()).is_equal("stagger")


func test_cooldown_between_attacks() -> void:
	_w.combat.set_cooldown(0.0)
	_w.combat.start(_attack("chanca_estocada"))
	await _until_attack_done()
	assert_bool(_w.combat.is_ready()).is_false()
	await _frames(int(_data.attack_cooldown_min * 60.0) - 10)
	assert_bool(_w.combat.is_attacking() and _w.combat.get_current() != null).is_false()


func test_occasional_block_after_a_hit_and_block_still_costs_posture() -> void:
	_enable_ai()
	_data.block_chance = 1.0
	_w.combat.set_cooldown(99.0)
	await _frames(10)
	_hit_enemy(10.0)
	await _frames(2)
	assert_str(_state()).is_equal("block")
	var health_before: float = _w.health.current
	var posture_before: float = _w.posture.current
	_hit_enemy(10.0)
	assert_float(_w.health.current).is_equal(health_before)
	assert_float(_w.posture.current).is_equal_approx(
		posture_before + 10.0 * _data.block_posture_factor, 0.01
	)


func test_heavy_hit_makes_it_back_off() -> void:
	_enable_ai()
	_data.block_chance = 0.0
	_w.combat.set_cooldown(99.0)
	await _frames(10)
	var before: float = _w.distance_to(_player.global_position)
	_hit_enemy(_data.retreat_posture_threshold)
	await _frames(2)
	assert_str(_state()).is_equal("retreat")
	await _frames(20)
	assert_float(_w.distance_to(_player.global_position)).is_greater(before + 0.8)


func test_hit_react_when_not_attacking_but_attack_goes_on_when_hit() -> void:
	_enable_ai()
	_data.block_chance = 0.0
	_w.combat.set_cooldown(99.0)
	await _frames(10)
	_hit_enemy(5.0)
	assert_bool((_w.get_node("HitFlash") as HitFlash).is_flashing()).is_true()
	_w.combat.start(_attack("chanca_golpe"))
	await _frames(5)
	_hit_enemy(5.0)
	assert_bool(_w.combat.is_attacking()).is_true()


func test_dead_warrior_stops_attacking() -> void:
	_w.combat.start(_attack("chanca_golpe"))
	await _frames(5)
	_w.health.apply_damage(_w.health.get_maximum())
	await _frames(2)
	assert_str(_state()).is_equal("dead")
	assert_bool(_w.combat.is_attacking()).is_false()
	assert_bool(_w.combat.hitbox.is_active()).is_false()


func test_lunge_stops_at_contact_distance() -> void:
	_w.global_position = Vector3(-8, 0.05, -4.0)  # 1.6 m: a full lunge (0.8 m) would overshoot
	await _frames(2)
	_w.combat.start(_attack("chanca_golpe"))
	await _until_attack_done()
	assert_float(_w.distance_to(_player.global_position)).is_greater(
		_data.attack_contact_distance - 0.25
	)
