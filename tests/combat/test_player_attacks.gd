extends GdUnitTestSuite
## Integration: player attacks in the greybox scene, next to Dummy3 (0,0,17).

const TEST_SCENE: String = "res://scenes/tests/locomotion_test.tscn"

var _runner: GdUnitSceneRunner
var _player: PlayerController
var _combat: CombatComponent
var _stamina: StaminaComponent
var _started: Array[StringName] = []


func before_test() -> void:
	_started.clear()
	_runner = scene_runner(TEST_SCENE)
	_player = _runner.find_child("Player") as PlayerController
	_combat = _player.get_node("Combat") as CombatComponent
	_stamina = _player.get_node("Stamina") as StaminaComponent
	_combat.attack_started.connect(func(d: AttackData) -> void: _started.append(d.id))
	_player.global_position = Vector3(0, 0.05, 15.6)
	_player.rotation.y = PI
	_player.velocity = Vector3.ZERO
	await _frames(5)


func after_test() -> void:
	Engine.time_scale = 1.0
	for action: StringName in [&"move_left", &"move_forward"]:
		Input.action_release(action)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _frames(count: int) -> void:
	for i: int in count:
		await get_tree().physics_frame


func _until_idle(max_frames: int = 240) -> void:
	for i: int in max_frames:
		if not _combat.is_attacking():
			return
		await get_tree().physics_frame


func _dummy_health() -> HealthComponent:
	return _runner.find_child("Dummy3").get_node("Health") as HealthComponent


func test_wiring_and_champi_in_right_hand() -> void:
	assert_int(_combat.light_chain.size()).is_equal(3)
	assert_object(_combat.heavy).is_not_null()
	assert_object(_combat.stamina).is_same(_stamina)
	var socket := _combat.hitbox.get_parent().get_parent() as BoneAttachment3D
	assert_str(socket.bone_name).is_equal("RightHand")


func test_light_attack_spends_stamina_and_damages_dummy() -> void:
	_combat.request(CombatComponent.Kind.LIGHT)
	assert_float(_stamina.current).is_equal(_stamina.get_maximum() - 12.0)
	assert_bool(_player.is_in_action()).is_true()
	await _until_idle()
	assert_float(_dummy_health().current).is_equal(_dummy_health().get_maximum() - 18.0)
	assert_bool(_player.is_in_action()).is_false()


func test_partial_stamina_attacks_and_empty_does_not() -> void:
	_stamina.drain(_stamina.get_maximum() - 5.0)
	_combat.request(CombatComponent.Kind.LIGHT)
	assert_bool(_combat.is_attacking()).is_true()
	assert_float(_stamina.current).is_equal(0.0)
	await _until_idle()
	_stamina.drain(_stamina.get_maximum())  # empty right now (regen may have started)
	_combat.request(CombatComponent.Kind.LIGHT)
	assert_bool(_combat.is_attacking()).is_false()


func test_mashing_chains_three_lights_then_wraps() -> void:
	for i: int in 260:
		_combat.request(CombatComponent.Kind.LIGHT)
		await get_tree().physics_frame
		if _started.size() >= 4:
			break
	assert_array(_started).contains_exactly([&"light_1", &"light_2", &"light_3", &"light_1"])


func test_heavy_breaks_the_chain() -> void:
	_combat.request(CombatComponent.Kind.LIGHT)
	await _frames(25)
	_combat.request(CombatComponent.Kind.HEAVY)
	await _until_idle()
	_combat.request(CombatComponent.Kind.LIGHT)
	assert_array(_started).contains_exactly([&"light_1", &"heavy", &"light_1"])


func test_hitbox_only_active_in_active_phase_and_hand_moves_fastest_then() -> void:
	_combat.request(CombatComponent.Kind.LIGHT)
	var speeds: Dictionary = {AttackRules.Phase.WINDUP: [], AttackRules.Phase.ACTIVE: []}
	var prev: Vector3 = _combat.hitbox.global_position
	for i: int in 60:
		await get_tree().physics_frame
		if not _combat.is_attacking():
			break
		var phase: AttackRules.Phase = _combat.get_phase()
		assert_bool(_combat.hitbox.is_active()).is_equal(phase == AttackRules.Phase.ACTIVE)
		var pos: Vector3 = _combat.hitbox.global_position
		if speeds.has(phase):
			(speeds[phase] as Array).append(pos.distance_to(prev) * 60.0)
		prev = pos
	var windup: float = _mean(speeds[AttackRules.Phase.WINDUP])
	var active: float = _mean(speeds[AttackRules.Phase.ACTIVE])
	assert_float(active).is_greater(windup * 2.0)


func test_attack_turns_to_stick_and_only_lunges() -> void:
	# Camera looks -Z, so "left" is -X: the attack faces there and only moves by its lunge.
	var start: Vector3 = _player.global_position
	Input.action_press(&"move_left")
	_combat.request(CombatComponent.Kind.LIGHT)
	await _frames(40)
	var moved: Vector3 = (_player.global_position - start) * Vector3(1, 0, 1)
	assert_float(moved.x).is_less(-0.1)
	assert_float(moved.length()).is_less_equal(_combat.light_chain[0].lunge_distance + 0.05)


func test_attack_clip_plays() -> void:
	var animator := _player.get_node("Animator") as CharacterAnimator
	_combat.request(CombatComponent.Kind.HEAVY)
	await _frames(5)
	assert_bool(animator.is_attack_playing()).is_true()


func _mean(values: Array) -> float:
	if values.is_empty():
		return 0.0
	var total: float = 0.0
	for v: float in values:
		total += v
	return total / values.size()
