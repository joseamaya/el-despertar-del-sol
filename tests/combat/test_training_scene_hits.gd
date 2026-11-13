extends GdUnitTestSuite
## Integration: debug swing (J) hits the dummies in the greybox scene.

const TEST_SCENE: String = "res://scenes/tests/locomotion_test.tscn"

var _runner: GdUnitSceneRunner
var _player: PlayerController
var _swing: DebugSwing


func before_test() -> void:
	_runner = scene_runner(TEST_SCENE)
	_player = _runner.find_child("Player") as PlayerController
	_swing = _player.get_node("DebugSwing") as DebugSwing
	# Stand 1 m in front of Dummy3 (0,0,17), facing it (+Z).
	_player.global_position = Vector3(0, 0.05, 15.9)
	_player.rotation.y = PI
	_player.velocity = Vector3.ZERO
	await _frames(5)


func after_test() -> void:
	Engine.time_scale = 1.0
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _frames(count: int) -> void:
	for i: int in count:
		await get_tree().physics_frame


func _dummy_health(index: int) -> HealthComponent:
	return _runner.find_child("Dummy%d" % index).get_node("Health") as HealthComponent


func test_wiring() -> void:
	assert_object(_swing.hitbox).is_not_null()
	assert_object(_swing.attacker).is_same(_player)
	assert_object(_player.get_node("Hurtbox")).is_instanceof(Hurtbox)
	var dummy := _runner.find_child("Dummy3") as TrainingDummy
	assert_object(dummy.hurtbox.health).is_same(dummy.health)


func test_swing_hits_dummy_in_front_once_and_flashes_it() -> void:
	var health := _dummy_health(3)
	_swing.swing()
	await _frames(20)
	assert_float(health.current).is_equal(health.get_maximum() - _swing.damage)
	assert_bool(_swing.is_swinging()).is_false()


func test_swing_does_not_hurt_the_player() -> void:
	var health := _player.get_node("Health") as HealthComponent
	_swing.swing()
	await _frames(20)
	assert_float(health.current).is_equal(health.get_maximum())


func test_dummy_dies_and_lock_releases() -> void:
	var lock := _player.get_node("LockOn") as LockOnController
	var rig := _runner.find_child("CameraRig") as CameraController
	rig.yaw = PI
	rig.tick(0.0)
	await _frames(3)
	lock.toggle_lock()
	assert_bool(lock.is_locked()).is_true()
	var target_dummy: Node = lock.get_target().get_parent()
	var health := target_dummy.get_node("Health") as HealthComponent
	health.apply_damage(health.get_maximum())
	await _frames(3)
	assert_bool(is_instance_valid(target_dummy)).is_false()
	assert_bool(lock.is_locked()).is_false()
