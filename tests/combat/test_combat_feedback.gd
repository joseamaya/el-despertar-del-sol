extends GdUnitTestSuite
## Seeing a block (F6 task 4): a blocked blow flashes at the head of the mace, drawn over
## the body, with sparks; an unguarded blow does not.

const SCENE: String = "res://scenes/tests/combat_arena.tscn"

var _runner: GdUnitSceneRunner
var _player: PlayerController
var _feedback: CombatFeedback
var _warrior: EnemyController


func before_test() -> void:
	_runner = scene_runner(SCENE)
	_player = _runner.find_child("Player") as PlayerController
	_feedback = _runner.find_child("CombatFeedback") as CombatFeedback
	(_runner.find_child("CameraRig") as CameraController).capture_mouse = false
	await _frames(5)
	var warriors: Array[EnemyController] = (
		(_runner.find_child("ArenaController") as ArenaController).alive_enemies()
	)
	_warrior = warriors[0]
	for i: int in range(1, warriors.size()):
		warriors[i].queue_free()
	_warrior.process_mode = Node.PROCESS_MODE_DISABLED
	_warrior.global_position = _player.global_position - _player.global_basis.z * 2.0


func after_test() -> void:
	Input.action_release(&"block")


func _frames(count: int) -> void:
	for i: int in count:
		await get_tree().physics_frame


func _blow() -> void:
	var info := HitInfo.new()
	info.damage = 5.0
	info.attacker = _warrior
	(_player.get_node(^"Hurtbox") as Hurtbox).receive_hit(info)


func test_a_blocked_blow_flashes_at_the_mace_with_sparks() -> void:
	var flashes: Array[Vector3] = []
	_feedback.block_flashed.connect(func(at: Vector3) -> void: flashes.append(at))
	Input.action_press(&"block")
	await _frames(20)
	var before: int = _feedback.get_child_count()
	_blow()
	assert_int(flashes.size()).is_equal(1)
	var mace: Node3D = _feedback.player_guard_point
	assert_object(mace).is_not_null()
	assert_vector(flashes[0]).is_equal_approx(mace.global_position, Vector3.ONE * 0.01)
	# The flash and every spark.
	assert_int(_feedback.get_child_count() - before).is_equal(1 + _feedback.feel.block_sparks)
	var flash := _feedback.get_child(before) as MeshInstance3D
	var material := (flash.mesh as SphereMesh).material as StandardMaterial3D
	assert_bool(material.no_depth_test).is_true()


func test_an_unguarded_blow_does_not_flash() -> void:
	var flashes: Array[Vector3] = []
	_feedback.block_flashed.connect(func(at: Vector3) -> void: flashes.append(at))
	_blow()
	assert_int(flashes.size()).is_equal(0)


func test_without_a_mace_it_flashes_in_front_toward_the_attacker() -> void:
	_feedback.player_guard_point = null
	var info := HitInfo.new()
	info.attacker = _warrior
	var at: Vector3 = _feedback.guard_point(info)
	var ahead: Vector3 = (at - _player.global_position) * _player.global_basis
	# In front (-Z), at guard height.
	assert_float(ahead.z).is_less(-0.3)
	assert_float(at.y - _player.global_position.y).is_equal_approx(1.2, 0.01)
