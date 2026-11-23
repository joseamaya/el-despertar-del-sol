extends GdUnitTestSuite
## The guard turns toward the blow (F6 task 3): the pure pick, and in the combat arena a
## guard held without a lock turns toward a warrior swinging from the side and stops his
## blows; with a lock it leaves the facing to the lock.

const SCENE: String = "res://scenes/tests/combat_arena.tscn"


func test_pick_takes_the_nearest_threat_within_reach() -> void:
	var origin := Vector3.ZERO
	var positions: Array[Vector3] = [Vector3(3, 0, 0), Vector3(0, 0, 2), Vector3(1, 0, 0)]
	var threats: Array[bool] = [true, true, false]
	# The nearest one is not swinging: the next nearest that is.
	assert_int(BlockFacing.pick(origin, positions, threats, 4.0)).is_equal(1)
	assert_int(BlockFacing.pick(origin, positions, threats, 1.5)).is_equal(-1)
	assert_int(BlockFacing.pick(origin, positions, [false, false, false], 4.0)).is_equal(-1)
	assert_int(BlockFacing.pick(origin, [], [], 4.0)).is_equal(-1)


func test_guard_turns_to_a_warrior_on_the_side_and_blocks_him() -> void:
	var runner := scene_runner(SCENE)
	var player := runner.find_child("Player") as PlayerController
	var arena := runner.find_child("ArenaController") as ArenaController
	var facing := player.get_node(^"BlockFacing") as BlockFacing
	(runner.find_child("CameraRig") as CameraController).capture_mouse = false
	await _frames(5)
	var warriors: Array[EnemyController] = arena.alive_enemies()
	for i: int in range(1, warriors.size()):
		warriors[i].queue_free()
	var warrior: EnemyController = warriors[0]
	# Put him at the player's right, so a still guard would not cover him.
	warrior.global_position = player.global_position + player.global_basis.x * 2.5
	warrior.perception.alert_to(player.global_position)
	var probe := BlockProbe.new()
	probe.player = player
	player.add_child(probe)
	Input.action_press(&"block")
	var faced: bool = false
	for i: int in 1500:
		await get_tree().physics_frame
		(player.get_node(^"Health") as HealthComponent).reset()
		faced = faced or facing.facing() == warrior.get_node(^"LockOnTarget")
		if probe.blows() >= 4:
			break
	Input.action_release(&"block")
	assert_bool(faced).is_true()
	assert_int(probe.blows()).is_greater_equal(4)
	assert_int(probe.landed.get(BlockProbe.OUTSIDE_ARC, 0) as int).is_equal(0)
	probe.queue_free()


func test_with_a_lock_it_leaves_the_facing_alone() -> void:
	var runner := scene_runner(SCENE)
	var player := runner.find_child("Player") as PlayerController
	var facing := player.get_node(^"BlockFacing") as BlockFacing
	var lock := player.get_node(^"LockOn") as LockOnController
	var rig := runner.find_child("CameraRig") as CameraController
	rig.capture_mouse = false
	await _frames(5)
	var warrior: EnemyController = (
		(runner.find_child("ArenaController") as ArenaController).alive_enemies()[0]
	)
	# In front and within lock range.
	warrior.global_position = player.global_position - player.global_basis.z * 3.0
	await _frames(2)
	var to: Vector3 = warrior.global_position - player.global_position
	rig.yaw = atan2(-to.x, -to.z)
	rig.snap_to_target()
	await _frames(2)
	lock.toggle_lock()
	assert_bool(lock.is_locked()).is_true()
	Input.action_press(&"block")
	await _frames(30)
	facing.tick()
	Input.action_release(&"block")
	assert_object(facing.facing()).is_null()


func _frames(count: int) -> void:
	for i: int in count:
		await get_tree().physics_frame
