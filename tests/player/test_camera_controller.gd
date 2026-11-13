extends GdUnitTestSuite
## Integration tests: the camera rig in the greybox test scene.

const TEST_SCENE: String = "res://scenes/tests/locomotion_test.tscn"
const PHYSICS_FRAMES_PER_SECOND: int = 60

var _runner: GdUnitSceneRunner
var _rig: CameraController
var _player: PlayerController


func before_test() -> void:
	_runner = scene_runner(TEST_SCENE)
	_rig = _runner.find_child("CameraRig") as CameraController
	_player = _runner.find_child("Player") as PlayerController


func after_test() -> void:
	Input.action_release(&"move_forward")
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _physics_frames(count: int) -> void:
	for i: int in count:
		await get_tree().physics_frame


func _place_player(pos: Vector3) -> void:
	_player.global_position = pos
	_player.velocity = Vector3.ZERO
	_rig.snap_to_target()
	await _physics_frames(5)


func test_rig_is_wired_and_drives_player_camera() -> void:
	assert_object(_rig.tuning).is_not_null()
	assert_object(_rig.target).is_same(_player)
	assert_object(_player.camera).is_same(_rig.camera)
	assert_bool(_rig.camera.current).is_true()


func test_camera_starts_behind_and_above_player() -> void:
	await _physics_frames(5)
	var cam_pos: Vector3 = _rig.camera.global_position
	var player_pos: Vector3 = _player.global_position
	assert_float(cam_pos.z).is_greater(player_pos.z + 2.0)  # behind: forward is -Z
	assert_float(cam_pos.y).is_greater(player_pos.y + _rig.tuning.pivot_height)


func test_rig_follows_player() -> void:
	await _place_player(Vector3(0, 0.05, 8))
	Input.action_press(&"move_forward")
	await _physics_frames(60)
	Input.action_release(&"move_forward")
	await _physics_frames(30)
	var pivot: Vector3 = _player.global_position + Vector3.UP * _rig.tuning.pivot_height
	assert_float(_rig.global_position.distance_to(pivot)).is_less(0.1)


func test_mouse_look_is_clamped() -> void:
	_rig.add_look_input(Vector2(0, -100000))
	assert_float(_rig.pitch).is_equal_approx(deg_to_rad(_rig.tuning.pitch_max_deg), 0.0001)


func test_forward_follows_camera_after_turning() -> void:
	await _place_player(Vector3(0, 0.05, 8))
	_rig.yaw = deg_to_rad(90.0)  # camera on +X, looking toward -X
	_rig.tick(0.0)
	var start: Vector3 = _player.global_position
	Input.action_press(&"move_forward")
	await _physics_frames(30)
	var moved: Vector3 = _player.global_position - start
	assert_float(moved.x).is_less(-1.0)
	assert_float(absf(moved.z)).is_less(0.2)


func test_wall_behind_pulls_camera_in() -> void:
	# LongWall: x 9.75..10.25, z -1..5, 2 m tall. Camera arm points to +X at yaw 90°.
	await _place_player(Vector3(8.5, 0.05, 2))
	_rig.yaw = deg_to_rad(90.0)
	_rig.pitch = 0.0
	_rig.tick(0.0)
	await _physics_frames(5)
	assert_float(_rig.spring_arm.get_hit_length()).is_less(1.5)
	assert_float(_rig.camera.global_position.x).is_less(9.75)


func test_open_space_keeps_full_distance() -> void:
	await _place_player(Vector3(0, 0.05, 8))
	await _physics_frames(5)
	assert_float(_rig.spring_arm.get_hit_length()).is_equal_approx(_rig.tuning.distance, 0.01)
