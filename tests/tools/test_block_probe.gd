extends GdUnitTestSuite
## The block probe of the F6 diagnosis (task 2): a guarded blow from the front counts as
## blocked; one from behind lands and is put down to the frontal arc; one with block not
## held is put down to that.

const SCENE: String = "res://scenes/tests/combat_arena.tscn"

var _runner: GdUnitSceneRunner
var _player: PlayerController
var _probe: BlockProbe


func before_test() -> void:
	_runner = scene_runner(SCENE)
	_player = _runner.find_child("Player") as PlayerController
	(_runner.find_child("CameraRig") as CameraController).capture_mouse = false
	for enemy: EnemyController in (
		(_runner.find_child("ArenaController") as ArenaController).alive_enemies()
	):
		enemy.queue_free()
	_probe = auto_free(BlockProbe.new()) as BlockProbe
	_probe.player = _player
	_player.add_child(_probe)
	await _frames(5)


func after_test() -> void:
	Input.action_release(&"block")


func _frames(count: int) -> void:
	for i: int in count:
		await get_tree().physics_frame


## A blow coming from `direction` (player's local frame: -Z is ahead).
func _blow(direction: Vector3) -> void:
	var info := HitInfo.new()
	info.damage = 1.0
	info.point = _player.global_position + _player.global_basis * direction * 1.5
	(_player.get_node(^"Hurtbox") as Hurtbox).receive_hit(info)


func test_front_blow_is_blocked_and_back_blow_is_outside_the_arc() -> void:
	Input.action_press(&"block")
	await _frames(20)
	_blow(Vector3.FORWARD)
	await _frames(40)
	_blow(Vector3.BACK)
	assert_int(_probe.blocked + _probe.parried).is_equal(1)
	assert_dict(_probe.landed).is_equal({BlockProbe.OUTSIDE_ARC: 1})
	assert_int(_probe.blows()).is_equal(2)
	assert_float(absf(_probe.angles[1])).is_greater(150.0)


func test_blow_without_guard_is_put_down_to_that() -> void:
	_blow(Vector3.FORWARD)
	assert_dict(_probe.landed).is_equal({BlockProbe.NOT_HELD: 1})
