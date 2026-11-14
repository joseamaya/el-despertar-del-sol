extends GdUnitTestSuite
## Integration: block, parry and dodge against the telegraphed test swing (H).
## The swing lands about 0.6 s (windup) + ~0.06 s after attack().

const TEST_SCENE: String = "res://scenes/tests/locomotion_test.tscn"
const WINDUP_FRAMES: int = 36

var _runner: GdUnitSceneRunner
var _player: PlayerController
var _defense: DefenseComponent
var _health: HealthComponent
var _stamina: StaminaComponent
var _combat: CombatComponent
var _enemy: DebugEnemyAttack
var _events: Array[String] = []


func before_test() -> void:
	_events.clear()
	_runner = scene_runner(TEST_SCENE)
	_player = _runner.find_child("Player") as PlayerController
	_defense = _player.get_node("Defense") as DefenseComponent
	_health = _player.get_node("Health") as HealthComponent
	_stamina = _player.get_node("Stamina") as StaminaComponent
	_combat = _player.get_node("Combat") as CombatComponent
	_enemy = _runner.find_child("DebugEnemyAttack") as DebugEnemyAttack
	_defense.blocked.connect(func(_i: HitInfo) -> void: _events.append("blocked"))
	_defense.parried.connect(func(_i: HitInfo) -> void: _events.append("parried"))
	_defense.evaded.connect(func(_i: HitInfo) -> void: _events.append("evaded"))
	_defense.guard_broken.connect(func() -> void: _events.append("guard_broken"))
	_player.global_position = Vector3(0, 0.05, 6)
	_player.rotation.y = 0.0
	_player.velocity = Vector3.ZERO
	await _frames(5)


func after_test() -> void:
	Engine.time_scale = 1.0
	for a: StringName in [&"block", &"dodge", &"move_left"]:
		Input.action_release(a)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _frames(count: int) -> void:
	for i: int in count:
		await get_tree().physics_frame


func _until_enemy_done() -> void:
	for i: int in 120:
		if not _enemy.is_attacking():
			return
		await get_tree().physics_frame


func test_wiring() -> void:
	assert_object((_player.get_node("Hurtbox") as Hurtbox).defense).is_same(_defense)
	assert_object(_defense.combat).is_same(_combat)


func test_undefended_swing_hits() -> void:
	_enemy.attack()
	await _until_enemy_done()
	assert_float(_health.current).is_equal(_health.get_maximum() - _enemy.damage)
	assert_array(_events).is_empty()


func test_holding_block_blocks_and_costs_stamina() -> void:
	Input.action_press(&"block")
	await _frames(5)
	_enemy.attack()
	await _until_enemy_done()
	assert_float(_health.current).is_equal(_health.get_maximum())
	assert_array(_events).contains_exactly(["blocked"])
	assert_float(_stamina.current).is_less_equal(_stamina.get_maximum() - 15.0 + 1.0)


func test_block_pressed_just_in_time_parries_for_free() -> void:
	_enemy.attack()
	await _frames(WINDUP_FRAMES - 2)
	Input.action_press(&"block")
	await _until_enemy_done()
	assert_float(_health.current).is_equal(_health.get_maximum())
	assert_array(_events).contains_exactly(["parried"])
	assert_float(_stamina.current).is_equal(_stamina.get_maximum())


func test_dodge_iframes_evade() -> void:
	_enemy.attack()
	await _frames(WINDUP_FRAMES - 2)
	assert_bool(_defense.request_dodge(Vector3(0, 0, 1))).is_true()
	await _until_enemy_done()
	assert_float(_health.current).is_equal(_health.get_maximum())
	assert_array(_events).contains_exactly(["evaded"])
	assert_float(_stamina.current).is_less_equal(_stamina.get_maximum() - 20.0 + 1.0)


func test_dodge_needs_whole_cost() -> void:
	_stamina.drain(_stamina.get_maximum() - 10.0)
	assert_bool(_defense.request_dodge()).is_false()
	assert_bool(_defense.is_dodging()).is_false()


func test_block_without_stamina_breaks_guard_and_stuns() -> void:
	Input.action_press(&"block")
	await _frames(5)
	_stamina.drain(_stamina.get_maximum() - 5.0)
	_stamina.set_physics_process(false)
	_enemy.attack()
	await _until_enemy_done()
	assert_array(_events).contains_exactly(["guard_broken"])
	assert_float(_health.current).is_equal(_health.get_maximum())
	assert_bool(_defense.is_stunned()).is_true()
	assert_bool(_player.is_in_action()).is_true()
	await _frames(60)
	assert_bool(_defense.is_stunned()).is_false()
	assert_bool(_player.is_in_action()).is_false()


func test_hit_from_behind_gets_through_the_block() -> void:
	Input.action_press(&"block")
	await _frames(5)
	_enemy.attack(true)
	await _until_enemy_done()
	assert_float(_health.current).is_equal(_health.get_maximum() - _enemy.damage)


func test_dodge_cancels_recovery_but_not_windup() -> void:
	_combat.request(CombatComponent.Kind.LIGHT)
	await _frames(2)
	assert_bool(_defense.request_dodge()).is_false()
	for i: int in 90:
		if _combat.get_phase() == AttackRules.Phase.RECOVERY:
			break
		await get_tree().physics_frame
	assert_bool(_defense.request_dodge()).is_true()
	assert_bool(_combat.is_attacking()).is_false()


func test_no_attack_while_dodging_and_slow_while_blocking() -> void:
	assert_bool(_defense.request_dodge()).is_true()
	_combat.request(CombatComponent.Kind.LIGHT)
	assert_bool(_combat.is_attacking()).is_false()
	await _frames(60)
	Input.action_press(&"block")
	Input.action_press(&"move_left")
	await _frames(40)
	assert_bool(_defense.is_blocking()).is_true()
	assert_float(_player.get_horizontal_speed()).is_less_equal(
		_defense.tuning.block_move_speed + 0.05
	)
