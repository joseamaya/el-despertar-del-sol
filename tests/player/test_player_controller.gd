extends GdUnitTestSuite
## Integration tests: the player in the greybox test scene, driven by input actions.

const TEST_SCENE: String = "res://scenes/tests/locomotion_test.tscn"
const PHYSICS_FRAMES_PER_SECOND: int = 60

var _runner: GdUnitSceneRunner
var _player: PlayerController


func before_test() -> void:
	_runner = scene_runner(TEST_SCENE)
	_player = _runner.find_child("Player") as PlayerController


func after_test() -> void:
	for action: StringName in [
		&"move_forward", &"move_back", &"move_left", &"move_right", &"sprint"
	]:
		Input.action_release(action)


func _hold(actions: Array[StringName], seconds: float) -> void:
	for action: StringName in actions:
		Input.action_press(action)
	await await_physics_frames(int(seconds * PHYSICS_FRAMES_PER_SECOND))
	for action: StringName in actions:
		Input.action_release(action)


func await_physics_frames(count: int) -> void:
	for i: int in count:
		await get_tree().physics_frame


func _place(pos: Vector3) -> void:
	_player.global_position = pos
	_player.velocity = Vector3.ZERO
	await await_physics_frames(10)


func test_scene_wires_player_with_tuning_and_camera() -> void:
	assert_object(_player).is_not_null()
	assert_object(_player.tuning).is_not_null()
	assert_object(_player.camera).is_not_null()


func test_player_rests_on_floor() -> void:
	await await_physics_frames(30)
	assert_bool(_player.is_on_floor()).is_true()


func test_forward_moves_away_from_camera_at_run_speed() -> void:
	await _place(Vector3(0, 0.05, 8))
	var start: Vector3 = _player.global_position
	Input.action_press(&"move_forward")
	await await_physics_frames(45)
	assert_float(_player.get_horizontal_speed()).is_equal_approx(_player.tuning.run_speed, 0.05)
	assert_float(_player.global_position.z).is_less(start.z - 1.0)
	# Facing follows the move direction (-Z).
	var facing: Vector3 = _player.global_basis * Vector3.FORWARD
	assert_float(facing.z).is_less(-0.95)


func test_sprint_reaches_sprint_speed() -> void:
	await _place(Vector3(0, 0.05, 8))
	Input.action_press(&"move_right")
	Input.action_press(&"sprint")
	await await_physics_frames(45)
	assert_bool(_player.is_sprinting).is_true()
	assert_float(_player.get_horizontal_speed()).is_equal_approx(_player.tuning.sprint_speed, 0.05)


func test_player_stops_after_release() -> void:
	await _place(Vector3(0, 0.05, 8))
	await _hold([&"move_left"], 0.75)
	await await_physics_frames(30)
	assert_float(_player.get_horizontal_speed()).is_less(0.01)


func test_player_climbs_stairs() -> void:
	# Stairs platform spans z -7..-11: 1.3 s at run speed ends near its middle.
	await _place(Vector3(6, 0.05, -2.5))
	await _hold([&"move_forward"], 1.3)
	assert_float(_player.global_position.y).is_greater(1.1)


func test_player_climbs_ramp() -> void:
	# Ramp platform spans z -10.3..-13.3: 2.0 s at run speed ends on it.
	await _place(Vector3(-6, 0.05, -2.5))
	await _hold([&"move_forward"], 2.0)
	assert_float(_player.global_position.y).is_greater(2.3)


func test_terrace_wall_blocks_player() -> void:
	await _place(Vector3(0, 0.05, -11))
	await _hold([&"move_forward"], 2.0)
	assert_float(_player.global_position.z).is_greater(-13.5)
	assert_float(_player.global_position.y).is_less(0.2)
