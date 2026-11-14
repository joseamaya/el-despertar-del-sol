extends GdUnitTestSuite
## Integration: breaking a dummy's posture with lights, executing it, and parries sending
## posture damage back to the attacker. Dummy3 stands at (0,0,17).

const TEST_SCENE: String = "res://scenes/tests/locomotion_test.tscn"

var _runner: GdUnitSceneRunner
var _player: PlayerController
var _combat: CombatComponent
var _dummy: TrainingDummy


func before_test() -> void:
	_runner = scene_runner(TEST_SCENE)
	_player = _runner.find_child("Player") as PlayerController
	_combat = _player.get_node("Combat") as CombatComponent
	_dummy = _runner.find_child("Dummy3") as TrainingDummy
	_player.global_position = Vector3(0, 0.05, 15.6)
	_player.rotation.y = PI
	_player.velocity = Vector3.ZERO
	await _frames(5)


func after_test() -> void:
	Engine.time_scale = 1.0
	Input.action_release(&"block")
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _frames(count: int) -> void:
	for i: int in count:
		await get_tree().physics_frame


func _until_idle() -> void:
	for i: int in 240:
		if not _combat.is_attacking():
			return
		await get_tree().physics_frame


func _break_posture_with_lights() -> void:
	(_player.get_node("Stamina") as StaminaComponent).tuning.regen_delay = 0.0
	for i: int in 400:
		if _dummy.posture.is_broken():
			return
		_combat.request(CombatComponent.Kind.LIGHT)
		await get_tree().physics_frame


func test_wiring() -> void:
	assert_object(_dummy.hurtbox.posture).is_same(_dummy.posture)
	assert_object(_combat.execution).is_not_null()


func test_hits_fill_posture_and_five_lights_break_it() -> void:
	_combat.request(CombatComponent.Kind.LIGHT)
	await _until_idle()
	assert_float(_dummy.posture.current).is_equal(_combat.light_chain[0].posture_damage)
	await _break_posture_with_lights()
	assert_bool(_dummy.posture.is_broken()).is_true()
	await _frames(12)  # the hit's red flash (0.12 s) gives way to the broken colour
	assert_bool(_dummy.shows_broken()).is_true()
	assert_float(_dummy.health.current).is_greater(0.0)


func test_light_next_to_broken_dummy_executes_it() -> void:
	_dummy.posture.apply(_dummy.posture.get_maximum())
	var executed: Array[StringName] = []
	_combat.attack_started.connect(func(d: AttackData) -> void: executed.append(d.id))
	_combat.request(CombatComponent.Kind.LIGHT)
	await _until_idle()
	await _frames(2)
	assert_array(executed).contains_exactly([&"execution"])
	assert_bool(is_instance_valid(_dummy)).is_false()


func test_no_execution_without_broken_posture_or_when_far() -> void:
	assert_object(_combat.find_executable()).is_null()
	_dummy.posture.apply(_dummy.posture.get_maximum())
	assert_object(_combat.find_executable()).is_same(_dummy.hurtbox)
	_player.global_position = Vector3(0, 0.05, 12.0)
	await _frames(2)
	assert_object(_combat.find_executable()).is_null()


func test_execution_ignores_the_targets_defense() -> void:
	var info := HitInfo.create(10.0)
	info.unblockable = true
	var hurt := _player.get_node("Hurtbox") as Hurtbox
	Input.action_press(&"block")
	await _frames(3)
	hurt.receive_hit(info)
	var health := _player.get_node("Health") as HealthComponent
	assert_float(health.current).is_equal(health.get_maximum() - 10.0)


func test_parry_sends_posture_damage_to_attacker() -> void:
	var defense := _player.get_node("Defense") as DefenseComponent
	var info := HitInfo.create(15.0, 0.0, _dummy)
	info.source_posture = _dummy.posture
	Input.action_press(&"block")
	defense.press_block()  # deterministic: a simulated press may miss "just pressed"
	await _frames(1)
	(_player.get_node("Hurtbox") as Hurtbox).receive_hit(info)
	assert_float(_dummy.posture.current).is_equal(defense.tuning.parry_posture_damage)


func test_mashing_turns_into_execution_once_posture_breaks() -> void:
	var ids: Array[StringName] = []
	_combat.attack_started.connect(func(d: AttackData) -> void: ids.append(d.id))
	(_player.get_node("Stamina") as StaminaComponent).tuning.regen_delay = 0.0
	for i: int in 600:
		if not is_instance_valid(_dummy):
			break
		_combat.request(CombatComponent.Kind.LIGHT)
		await get_tree().physics_frame
	assert_bool(is_instance_valid(_dummy)).is_false()
	assert_array(ids).contains([&"execution"])
