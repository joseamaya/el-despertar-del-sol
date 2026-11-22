extends GdUnitTestSuite
## Integration: the benchmark drivers for sector levels (F3 task 10). The walk driver
## clears the enemies, follows the path and names the stretch; the fight driver fights at
## one encounter zone with only its warriors.

const SCENE: String = "res://scenes/levels/carmenca.tscn"

var _scene: Node
var _level: SectorLevel
var _arena: ArenaController


func _load(driver: Node) -> void:
	_scene = (load(SCENE) as PackedScene).instantiate()
	_level = _scene.find_child("SectorLevel", true, false) as SectorLevel
	_arena = _scene.find_child("ArenaController", true, false) as ArenaController
	(_scene.find_child("CameraRig", true, false) as CameraController).capture_mouse = false
	if driver is SectorWalkDriver:
		(driver as SectorWalkDriver).level = _level
		(driver as SectorWalkDriver).arena = _arena
	elif driver is ArenaFightDriver:
		(driver as ArenaFightDriver).level = _level
		(driver as ArenaFightDriver).arena = _arena
	_scene.add_child(driver)
	add_child(_scene)


func after_test() -> void:
	Engine.time_scale = 1.0
	Input.action_release(&"move_forward")
	Input.action_release(&"block")
	if is_instance_valid(_scene):
		_scene.free()


func _frames(count: int) -> void:
	for i: int in count:
		await get_tree().physics_frame


func test_walk_clears_enemies_follows_the_path_and_names_stretches() -> void:
	var walker := SectorWalkDriver.new()
	_load(walker)
	await _frames(5)
	# The opening shots, the first talk and the training hold the player (F5, build
	# 0.1.1): skip them, as a player in a hurry would.
	var slice := _scene.find_child("SliceDirector", true, false) as SliceDirector
	var talk := _scene.find_child("DialoguePlayer", true, false) as DialoguePlayer
	slice.skip_intro()
	slice.flow.set_flag(&"skip_training")
	while talk.is_playing():
		talk.advance()
	await _frames(2)
	assert_int(_arena.alive_enemies().size()).is_equal(0)
	assert_str(walker.stretch()).is_equal("mirador")
	Engine.time_scale = 3.0
	var seen: Dictionary = {}
	for i: int in 900:
		await get_tree().physics_frame
		seen[walker.stretch()] = true
		if seen.has("terrazas"):
			break
	assert_bool(seen.has("terrazas")).is_true()
	assert_float(walker.progress()).is_greater(0.05)
	assert_bool(walker.is_done()).is_false()


func test_fight_zone_keeps_only_that_zones_warriors() -> void:
	var fight := ArenaFightDriver.new()
	fight.zone = 3
	_load(fight)
	await _frames(5)
	var centre: Vector3 = _level.marker_position(&"Encounter3")
	var player := _level.player
	(
		assert_float(
			(
				Vector2(player.global_position.x - centre.x, player.global_position.z - centre.z)
				. length()
			)
		)
		. is_less(5.0)
	)
	var alive: int = 0
	for enemy: EnemyController in _arena.alive_enemies():
		if not enemy.is_queued_for_deletion():
			alive += 1
	assert_int(alive).is_equal(_level.layout.encounter_enemies[2])
