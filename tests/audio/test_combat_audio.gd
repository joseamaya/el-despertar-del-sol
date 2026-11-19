extends GdUnitTestSuite
## Integration: combat sounds per event, and impact feedback (shake, parry, execution).
## Warrior1 at (-8,0,-4) facing +Z, player 1.6 m in front; AI frozen.

const TEST_SCENE: String = "res://scenes/tests/enemy_test.tscn"

var _runner: GdUnitSceneRunner
var _player: PlayerController
var _w: EnemyController
var _player_audio: CombatAudio
var _enemy_audio: CombatAudio
var _rig: CameraController
var _player_events: Array[StringName] = []
var _enemy_events: Array[StringName] = []


func before_test() -> void:
	_player_events.clear()
	_enemy_events.clear()
	_runner = scene_runner(TEST_SCENE)
	_player = _runner.find_child("Player") as PlayerController
	_w = _runner.find_child("Warrior1") as EnemyController
	_rig = _runner.find_child("CameraRig") as CameraController
	for n: String in ["Warrior2", "Warrior3"]:
		(_runner.find_child(n) as Node).process_mode = Node.PROCESS_MODE_DISABLED
	_w.state_machine.set_physics_process(false)
	_w.combat.set_cooldown(99.0)
	_player.global_position = Vector3(-8, 0.05, -2.4)
	_player.rotation.y = 0.0
	_player_audio = _player.get_node("CombatAudio") as CombatAudio
	_enemy_audio = _w.get_node("CombatAudio") as CombatAudio
	_player_audio.sound_played.connect(func(e: StringName) -> void: _player_events.append(e))
	_enemy_audio.sound_played.connect(func(e: StringName) -> void: _enemy_events.append(e))
	await _frames(3)


func after_test() -> void:
	Engine.time_scale = 1.0
	Input.action_release(&"block")
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _frames(count: int) -> void:
	for i: int in count:
		await get_tree().physics_frame


func _golpe() -> AttackData:
	return load("res://resources/combat/attacks/enemy/chanca_golpe.tres") as AttackData


func _until_attack_done() -> void:
	for i: int in 240:
		if not _w.combat.is_attacking():
			return
		await get_tree().physics_frame


func test_every_event_has_sounds() -> void:
	for e: StringName in [&"hit", &"hit_heavy", &"blocked", &"parried", &"evaded", &"death"]:
		assert_bool(_player_audio.has_event(e)).is_true()
	for e: StringName in [&"hit", &"hit_heavy", &"blocked", &"telegraph", &"death"]:
		assert_bool(_enemy_audio.has_event(e)).is_true()


func test_enemy_windup_is_audible_and_player_hit_sounds() -> void:
	_w.combat.start(_golpe())
	assert_array(_enemy_events).contains([&"telegraph"])
	await _until_attack_done()
	assert_array(_player_events).contains([&"hit"])


func test_block_and_parry_sound_different() -> void:
	Input.action_press(&"block")
	await _frames(12)
	_w.combat.start(_golpe())
	await _until_attack_done()
	assert_array(_player_events).contains([&"blocked"])
	var defense := _player.get_node("Defense") as DefenseComponent
	_w.global_position = Vector3(-8, 0.05, -4)
	_w.combat.start(_golpe())
	for i: int in 240:
		defense.press_block()
		await get_tree().physics_frame
		if not _w.combat.is_attacking():
			break
	assert_array(_player_events).contains([&"parried"])


func test_heavy_hit_and_death_on_enemy() -> void:
	(_w.get_node("Hurtbox") as Hurtbox).receive_hit(HitInfo.create(10.0, 25.0, _player))
	assert_array(_enemy_events).contains([&"hit_heavy"])
	_w.health.apply_damage(_w.health.get_maximum())
	assert_array(_enemy_events).contains([&"death"])


func test_camera_shake_adds_decays_and_can_be_disabled() -> void:
	_rig.add_shake(0.6)
	assert_float(_rig.get_shake()).is_equal_approx(0.6, 0.05)
	await _frames(40)
	assert_float(_rig.get_shake()).is_equal(0.0)
	var calm := _rig.tuning.duplicate() as CameraTuning
	calm.shake_enabled = false
	_rig.tuning = calm
	_rig.add_shake(0.6)
	assert_float(_rig.get_shake()).is_equal(0.0)


func test_being_hurt_shakes_the_camera() -> void:
	_w.combat.start(_golpe())
	var shaken: bool = false
	for i: int in 240:
		await get_tree().physics_frame
		shaken = shaken or _rig.get_shake() > 0.0
		if not _w.combat.is_attacking():
			break
	assert_bool(shaken).is_true()


func test_parry_freezes_longer_and_flashes() -> void:
	var feedback := _runner.find_child("CombatFeedback") as CombatFeedback
	var flashes: Array[int] = [0]
	var stops: Array[float] = []
	var max_shake: Array[float] = [0.0]
	# The shake is added just before the flash: read it there, not on a later frame where
	# a slow runner may already have let it decay.
	feedback.parry_flashed.connect(
		func(_at: Vector3) -> void:
			flashes[0] += 1
			max_shake[0] = maxf(max_shake[0], _rig.get_shake())
	)
	var defense := _player.get_node("Defense") as DefenseComponent
	Input.action_press(&"block")
	_w.combat.start(_golpe())
	# Process frames keep running during hitstop (physics frames do not).
	var deadline: int = Time.get_ticks_msec() + 6000
	while _w.combat.is_attacking() and Time.get_ticks_msec() < deadline:
		defense.press_block()
		await get_tree().process_frame
		if Engine.time_scale < 1.0:
			stops.append(Engine.time_scale)
		max_shake[0] = maxf(max_shake[0], _rig.get_shake())
	assert_int(flashes[0]).is_equal(1)
	assert_array(stops).is_not_empty()
	assert_float(max_shake[0]).is_greater(0.0)


func test_execution_freezes_and_shakes() -> void:
	var combat := _player.get_node("Combat") as CombatComponent
	_w.posture.apply(_w.posture.get_maximum())
	await _frames(2)
	_player.global_position = _w.global_position + Vector3(0, 0, 1.4)
	_player.rotation.y = 0.0
	await _frames(2)
	assert_bool(_w.posture.is_broken()).is_true()
	assert_object(combat.find_executable()).is_not_null()
	var frozen: bool = false
	combat.request(CombatComponent.Kind.LIGHT)
	# Sample on process frames: during hitstop game time barely moves, so no physics
	# frame happens while it lasts.
	var deadline: int = Time.get_ticks_msec() + 5000
	while combat.is_attacking() and Time.get_ticks_msec() < deadline:
		await get_tree().process_frame
		frozen = frozen or Engine.time_scale < 1.0
	assert_bool(frozen).is_true()
	assert_bool(_w.is_dead()).is_true()
