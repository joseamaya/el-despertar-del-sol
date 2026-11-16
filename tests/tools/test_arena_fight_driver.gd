extends GdUnitTestSuite
## Integration: the benchmark fight driver keeps the arena fighting with N enemies.

const ARENA: String = "res://scenes/tests/combat_arena.tscn"

var _scene: Node
var _arena: ArenaController


func _load_arena(enemies: int) -> void:
	_scene = (load(ARENA) as PackedScene).instantiate()
	_arena = _scene.find_child("ArenaController") as ArenaController
	ArenaFightDriver.set_enemy_count(_arena, enemies)
	var driver := ArenaFightDriver.new()
	driver.arena = _arena
	_scene.add_child(driver)
	add_child(_scene)


func after_test() -> void:
	Engine.time_scale = 1.0
	if is_instance_valid(_scene):
		_scene.free()
	Input.action_release(&"block")


func _frames(count: int) -> void:
	for i: int in count:
		await get_tree().physics_frame


func test_extra_spawn_points_are_capped() -> void:
	var scene: Node = (load(ARENA) as PackedScene).instantiate()
	var arena := scene.find_child("ArenaController") as ArenaController
	assert_int(ArenaFightDriver.set_enemy_count(arena, 2)).is_equal(3)
	assert_int(ArenaFightDriver.set_enemy_count(arena, 99)).is_equal(6)
	scene.free()


func test_four_enemies_engage_and_nobody_dies() -> void:
	_load_arena(4)
	await _frames(240)
	var player := _arena.player
	assert_int(_arena.alive_enemies().size()).is_equal(4)
	assert_bool(_arena.is_in_combat()).is_true()
	assert_bool((player.get_node("Health") as HealthComponent).is_dead()).is_false()
	assert_int(_arena.state).is_equal(ArenaController.EncounterState.FIGHTING)
	assert_float(player.global_position.distance_to(ArenaFightDriver.FIGHT_SPOT)).is_less(4.0)
