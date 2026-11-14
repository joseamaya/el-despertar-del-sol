extends GdUnitTestSuite
## Integration: the chanca warrior senses, alerts, chases, circles, loses track, staggers
## and dies in enemy_test.tscn. Warrior1 starts at (-8,0,-4) facing +Z.

const TEST_SCENE: String = "res://scenes/tests/enemy_test.tscn"

var _runner: GdUnitSceneRunner
var _player: PlayerController
var _w1: EnemyController
var _w2: EnemyController


func before_test() -> void:
	_runner = scene_runner(TEST_SCENE)
	_player = _runner.find_child("Player") as PlayerController
	_w1 = _runner.find_child("Warrior1") as EnemyController
	_w2 = _runner.find_child("Warrior2") as EnemyController
	_w2.process_mode = Node.PROCESS_MODE_DISABLED
	(_runner.find_child("Warrior3") as Node).process_mode = Node.PROCESS_MODE_DISABLED
	_place_player(Vector3(18, 0.05, 18))
	await _frames(3)


func after_test() -> void:
	Engine.time_scale = 1.0
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _frames(count: int) -> void:
	for i: int in count:
		await get_tree().physics_frame


func _place_player(pos: Vector3) -> void:
	_player.global_position = pos
	_player.velocity = Vector3.ZERO


func _state(enemy: EnemyController) -> String:
	return String(enemy.state_machine.current_name())


func _until_state(enemy: EnemyController, state: String, max_frames: int) -> void:
	for i: int in max_frames:
		if _state(enemy) == state:
			return
		await get_tree().physics_frame


func test_wiring() -> void:
	assert_object(_w1.data).is_not_null()
	assert_object(_w1.perception.target).is_same(_player)
	assert_object(_w1.nav_agent).is_not_null()
	assert_float(_w1.health.get_maximum()).is_equal(100.0)
	assert_int((_w1.get_node("Hurtbox") as Hurtbox).faction).is_equal(HitRules.Faction.CHANCA)
	assert_str(_state(_w1)).is_equal("idle")


func test_does_not_see_behind_beyond_hearing() -> void:
	_place_player(Vector3(-12, 0.05, -10))  # ~7 m, behind-left
	await _frames(60)
	assert_str(_state(_w1)).is_equal("idle")


func test_hears_close_behind() -> void:
	_place_player(Vector3(-10, 0.05, -6.5))  # ~3 m behind
	await _until_state(_w1, "alert", 10)
	assert_str(_state(_w1)).is_equal("alert")


func test_wall_blocks_sight() -> void:
	_w1.global_position = Vector3(14, 0.05, 2)
	_w1.rotation.y = PI / 2.0  # facing -X, toward the long wall
	_w1.home_position = _w1.global_position
	_place_player(Vector3(7, 0.05, 2))  # 7 m away, wall in between
	await _frames(60)
	assert_str(_state(_w1)).is_equal("idle")


func test_sees_in_front_then_alerts_then_chases() -> void:
	_place_player(Vector3(-8, 0.05, 6))  # 10 m in front
	await _frames(3)
	assert_str(_state(_w1)).is_equal("alert")
	assert_bool(_w1.alert_marker.visible).is_true()
	await _frames(int(_w1.data.alert_time * 60.0) + 5)
	assert_str(_state(_w1)).is_equal("chase")
	assert_bool(_w1.alert_marker.visible).is_false()


func test_chases_and_circles_at_engage_distance() -> void:
	_w1.combat.set_cooldown(99.0)  # circling only: no attacks in this test
	_place_player(Vector3(-8, 0.05, 6))
	await _until_state(_w1, "strafe", 360)
	assert_str(_state(_w1)).is_equal("strafe")
	for i: int in 120:
		await get_tree().physics_frame
		var d: float = _w1.distance_to(_player.global_position)
		assert_float(d).is_between(_w1.data.engage_distance - 0.9, _w1.data.engage_distance + 0.9)
	assert_float(_w1.get_horizontal_speed()).is_greater(0.5)


func test_loses_track_and_goes_home() -> void:
	_place_player(Vector3(-8, 0.05, 6))
	await _until_state(_w1, "strafe", 360)
	_place_player(Vector3(18, 0.05, 18))
	await _until_state(_w1, "idle", 600)
	assert_str(_state(_w1)).is_equal("idle")
	var before: float = _w1.distance_to(_w1.home_position)
	await _frames(60)
	assert_float(_w1.distance_to(_w1.home_position)).is_less(before)


func test_broken_posture_staggers_and_is_executable() -> void:
	_place_player(Vector3(-8, 0.05, 6))
	await _until_state(_w1, "chase", 120)
	_w1.posture.apply(_w1.posture.get_maximum())
	await _frames(20)
	assert_str(_state(_w1)).is_equal("stagger")
	assert_float(_w1.get_horizontal_speed()).is_less(0.1)
	assert_bool((_w1.get_node("Hurtbox") as Hurtbox).is_executable()).is_true()
	await _frames(int(_w1.posture.tuning.broken_duration * 60.0) + 5)
	assert_str(_state(_w1)).is_not_equal("stagger")


func test_dies_stops_colliding_and_disappears() -> void:
	_w1.health.apply_damage(_w1.health.get_maximum())
	await _frames(2)
	assert_str(_state(_w1)).is_equal("dead")
	assert_int(_w1.collision_layer).is_equal(0)
	assert_int((_w1.get_node("Hurtbox") as Area3D).collision_layer).is_equal(0)
	await _frames(int(_w1.data.corpse_time * 60.0) + 10)
	assert_bool(is_instance_valid(_w1)).is_false()


func test_patrols_between_points() -> void:
	_w2.process_mode = Node.PROCESS_MODE_INHERIT
	var start: Vector3 = _w2.global_position
	await _frames(240)
	assert_str(_state(_w2)).is_equal("patrol")
	assert_float(_w2.global_position.distance_to(start)).is_greater(3.0)
