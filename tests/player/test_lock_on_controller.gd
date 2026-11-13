extends GdUnitTestSuite
## Integration tests: lock-on in the greybox scene. The camera is turned to look +Z,
## where Dummy1 (-4,0,13), Dummy2 (4,0,13) and Dummy3 (0,0,17) stand; Dummy4 (-12,0,9)
## is far off to the side.

const TEST_SCENE: String = "res://scenes/tests/locomotion_test.tscn"

var _runner: GdUnitSceneRunner
var _player: PlayerController
var _rig: CameraController
var _lock: LockOnController
var _released: Array[int] = []


func before_test() -> void:
	_released.clear()
	_runner = scene_runner(TEST_SCENE)
	_player = _runner.find_child("Player") as PlayerController
	_rig = _runner.find_child("CameraRig") as CameraController
	_lock = _player.get_node("LockOn") as LockOnController
	_lock.target_released.connect(_on_released)
	_player.global_position = Vector3(0, 0.05, 8)
	_player.velocity = Vector3.ZERO
	_rig.yaw = PI
	_rig.snap_to_target()
	await _frames(5)


func after_test() -> void:
	for action: StringName in [&"move_left", &"move_right", &"look_left", &"look_right"]:
		Input.action_release(action)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _frames(count: int) -> void:
	for i: int in count:
		await get_tree().physics_frame


func _dummy(index: int) -> Node3D:
	return _runner.find_child("Dummy%d" % index) as Node3D


func _on_released(reason: int) -> void:
	_released.append(reason)


func test_lock_on_is_wired() -> void:
	assert_object(_lock.tuning).is_not_null()
	assert_object(_lock.camera).is_same(_rig.camera)
	assert_object(_lock.body).is_same(_player)


func test_lock_picks_centered_target_and_notifies_camera_and_player() -> void:
	_lock.toggle_lock()
	assert_bool(_lock.is_locked()).is_true()
	assert_object(_lock.get_target().get_parent()).is_same(_dummy(3))
	assert_object(_rig.get_lock_target()).is_same(_lock.get_target())


func test_far_side_dummy_is_not_picked() -> void:
	_rig.yaw = 0.0  # looking -Z: no dummy in front within the pick angle
	_rig.tick(0.0)
	_lock.toggle_lock()
	assert_bool(_lock.is_locked()).is_false()


func test_camera_and_player_turn_to_target() -> void:
	_lock.toggle_lock()
	await _frames(60)
	var target_pos: Vector3 = _lock.get_target().global_position
	var expected_yaw: float = CameraMath.yaw_towards(_player.global_position, target_pos)
	assert_float(absf(angle_difference(_rig.yaw, expected_yaw))).is_less(0.05)
	var facing: Vector3 = _player.global_basis * Vector3.FORWARD
	var to_target: Vector3 = (target_pos - _player.global_position) * Vector3(1, 0, 1)
	assert_float(facing.angle_to(to_target.normalized())).is_less(0.1)


func test_mouse_does_not_orbit_while_locked() -> void:
	_lock.toggle_lock()
	await _frames(30)
	var yaw_before: float = _rig.yaw
	_rig.add_look_input(Vector2(500, 0))
	assert_float(_rig.yaw).is_equal_approx(yaw_before, 0.0001)


func test_switch_moves_to_neighbor_on_screen_side() -> void:
	_lock.toggle_lock()
	await _frames(30)
	var basis: Basis = _rig.camera.global_basis
	assert_bool(_lock.switch_target(1)).is_true()
	var side: float = LockOnMath.view_angle(
		_player.global_position, _lock.get_target().global_position, basis
	)
	assert_float(side).is_greater(0.0)
	assert_object(_rig.get_lock_target()).is_same(_lock.get_target())


func test_switch_respects_cooldown() -> void:
	_lock.toggle_lock()
	assert_bool(_lock.switch_target(1)).is_true()
	assert_bool(_lock.switch_target(-1)).is_false()


func test_mouse_flick_switches_target() -> void:
	_lock.toggle_lock()
	var first: LockOnTarget = _lock.get_target()
	_lock.add_mouse_motion(Vector2(_lock.tuning.mouse_switch_threshold + 5.0, 0))
	assert_object(_lock.get_target()).is_not_same(first)


func test_button_releases() -> void:
	_lock.toggle_lock()
	_lock.toggle_lock()
	assert_bool(_lock.is_locked()).is_false()
	assert_array(_released).contains_exactly([LockOnController.ReleaseReason.BUTTON])
	assert_object(_rig.get_lock_target()).is_null()


func test_moving_away_releases() -> void:
	_lock.toggle_lock()
	_player.global_position = Vector3(0, 0.05, -6)  # 23 m from Dummy3
	await _frames(3)
	assert_array(_released).contains_exactly([LockOnController.ReleaseReason.OUT_OF_RANGE])


func test_removed_target_releases() -> void:
	_lock.toggle_lock()
	_dummy(3).queue_free()
	await _frames(2)
	assert_bool(_lock.is_locked()).is_false()
	assert_array(_released).contains_exactly([LockOnController.ReleaseReason.TARGET_LOST])
	assert_object(_rig.get_lock_target()).is_null()


func test_strafing_while_locked_faces_move_then_target_again() -> void:
	_lock.toggle_lock()
	await _frames(30)
	Input.action_press(&"move_right")
	await _frames(30)
	var move_dir: Vector3 = (_player.velocity * Vector3(1, 0, 1)).normalized()
	var facing: Vector3 = _player.global_basis * Vector3.FORWARD
	assert_float(facing.angle_to(move_dir)).is_less(0.2)
	Input.action_release(&"move_right")
	await _frames(45)
	var to_target: Vector3 = _lock.get_target().global_position - _player.global_position
	to_target.y = 0.0
	facing = _player.global_basis * Vector3.FORWARD
	assert_float(facing.angle_to(to_target.normalized())).is_less(0.1)
