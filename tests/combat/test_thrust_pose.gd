extends GdUnitTestSuite
## The lancer's procedural thrust (F9 task 8): the timeline of the pose, the turns of the
## bones, and the spear going forward level with the thrust in the lancer scene.

const LANCER: String = "res://scenes/enemies/chanca_lancer.tscn"
const SHARE: float = 0.4


func _attack() -> AttackData:
	var attack := AttackData.new()
	attack.thrust = true
	attack.clip = &"Idle"
	attack.clip_speed = 1.0
	attack.windup_end = 0.5
	attack.active_end = 0.7
	attack.recovery_end = 1.3
	attack.lunge_distance = 0.0
	return attack


func test_progress_rest_drawn_thrust_and_back() -> void:
	var a: AttackData = _attack()
	assert_float(ThrustPose.progress(0.0, a, SHARE)).is_equal_approx(0.0, 0.001)
	assert_float(ThrustPose.progress(0.25, a, SHARE)).is_between(0.1, 0.9)
	assert_float(ThrustPose.progress(0.5, a, SHARE)).is_equal_approx(1.0, 0.001)
	# The strike takes SHARE of the active window (0.2 s): out at 0.58 s, then held.
	assert_float(ThrustPose.progress(0.58, a, SHARE)).is_equal_approx(2.0, 0.001)
	assert_float(ThrustPose.progress(0.65, a, SHARE)).is_equal_approx(2.0, 0.001)
	assert_float(ThrustPose.progress(1.0, a, SHARE)).is_between(0.1, 1.9)
	assert_float(ThrustPose.progress(1.3, a, SHARE)).is_equal_approx(0.0, 0.001)


func test_progress_follows_the_clip_speed() -> void:
	var a: AttackData = _attack()
	a.clip_speed = 0.5
	# Clip seconds at half speed: the windup ends at 1.0 real seconds.
	assert_float(ThrustPose.progress(1.0, a, SHARE)).is_equal_approx(1.0, 0.001)


func test_turn_goes_through_drawn_to_thrust_and_straight_back() -> void:
	var drawn := Quaternion.from_euler(Vector3(0, 0, 0.7))
	var thrust := Quaternion.from_euler(Vector3(0, 0, -1.3))
	(
		assert_bool(ThrustPose.turn(0.0, drawn, thrust, false).is_equal_approx(Quaternion.IDENTITY))
		. is_true()
	)
	assert_bool(ThrustPose.turn(1.0, drawn, thrust, false).is_equal_approx(drawn)).is_true()
	assert_bool(ThrustPose.turn(2.0, drawn, thrust, false).is_equal_approx(thrust)).is_true()
	assert_bool(ThrustPose.turn(2.0, drawn, thrust, true).is_equal_approx(thrust)).is_true()
	var back: Quaternion = ThrustPose.turn(1.0, drawn, thrust, true)
	assert_bool(back.is_equal_approx(Quaternion.IDENTITY.slerp(thrust, 0.5))).is_true()


func test_spear_pitch_levels_with_the_thrust() -> void:
	assert_float(ThrustPose.spear_pitch(0.5, 20.0, 0.0)).is_equal_approx(20.0, 0.001)
	assert_float(ThrustPose.spear_pitch(1.5, 20.0, 0.0)).is_equal_approx(10.0, 0.001)
	assert_float(ThrustPose.spear_pitch(2.0, 20.0, 0.0)).is_equal_approx(0.0, 0.001)


func test_lancer_scene_has_the_spear_and_no_mace() -> void:
	var lancer: EnemyController = auto_free((load(LANCER) as PackedScene).instantiate())
	var pose: ThrustPose = lancer.find_children("ThrustPose", "ThrustPose", true, false)[0]
	assert_object(pose.spear).is_not_null()
	assert_object(pose.combat).is_same(lancer.combat)
	assert_object(pose.body).is_same(lancer)
	var mace: Node3D = lancer.find_children("Mace", "Node3D", true, false)[0]
	assert_bool((mace.get_node(^"Handle") as Node3D).visible).is_false()
	assert_bool((mace.get_node(^"Head") as Node3D).visible).is_false()


func test_the_spear_goes_forward_level_with_the_thrust() -> void:
	var runner: GdUnitSceneRunner = scene_runner(LANCER)
	var lancer := runner.scene() as EnemyController
	lancer.director = null
	lancer.perception.target = null
	lancer.state_machine.process_mode = Node.PROCESS_MODE_DISABLED
	lancer.combat.set_physics_process(false)
	var tip: Node3D = lancer.find_children("Tip", "Marker3D", true, false)[0]
	await _frames(5)
	lancer.combat.start(_attack())
	var drawn: Vector3 = await _tip_at(lancer, tip, 0.5)
	var out: Vector3 = await _tip_at(lancer, tip, 0.1)
	var front: Vector3 = -lancer.global_basis.z
	var reach: float = (out - drawn).dot(front)
	assert_float(reach).override_failure_message("the tip went %.2f m" % reach).is_greater(0.6)
	var spear: Node3D = tip.get_parent() as Node3D
	assert_float(absf(spear.global_basis.x.normalized().y)).is_less(0.1)


## Advances the attack by `seconds` and returns where the tip is once drawn.
func _tip_at(lancer: EnemyController, tip: Node3D, seconds: float) -> Vector3:
	var left: float = seconds
	while left > 0.0:
		var dt: float = minf(1.0 / 60.0, left)
		lancer.combat.tick(dt)
		left -= dt
	await _frames(3)
	return tip.global_position


func _frames(count: int) -> void:
	for i: int in count:
		await get_tree().process_frame
