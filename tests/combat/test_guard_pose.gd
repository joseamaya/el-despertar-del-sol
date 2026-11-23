extends GdUnitTestSuite
## The guard pose (F6 task 4): while blocking, the arms rise over the animation, as much
## as the animator's guard blend; when the guard drops, they go back.

const SCENE: String = "res://scenes/tests/combat_arena.tscn"


func _frames(count: int) -> void:
	for i: int in count:
		await get_tree().physics_frame


func test_the_arms_rise_while_blocking_and_drop_after() -> void:
	var runner := scene_runner(SCENE)
	var player := runner.find_child("Player") as PlayerController
	(runner.find_child("CameraRig") as CameraController).capture_mouse = false
	for enemy: EnemyController in (
		(runner.find_child("ArenaController") as ArenaController).alive_enemies()
	):
		enemy.queue_free()
	var guard := player.find_child("GuardPose", true, false) as GuardPose
	var mace := player.find_child("Head", true, false) as Node3D
	assert_object(guard).is_not_null()
	Input.action_press(&"block")
	await _frames(40)
	assert_float(guard.influence).is_greater(0.9)
	var raised: Vector3 = mace.global_position - player.global_position
	# The same guard without the pose: the mace where the animation alone leaves it.
	guard.active = false
	await _frames(3)
	var flat: Vector3 = mace.global_position - player.global_position
	guard.active = true
	Input.action_release(&"block")
	await _frames(40)
	assert_float(guard.influence).is_less(0.1)
	assert_float(raised.distance_to(flat)).is_greater(0.3)
	assert_float(raised.y).is_greater(flat.y)
