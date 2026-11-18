extends GdUnitTestSuite
## Integration: the Carmenca blockout is walkable — stairs both ways, the whole path —
## and going down the stairs keeps the player on the ground (F1 debt: 0.25 m step).

const SCENE: String = "res://scenes/levels/carmenca.tscn"
## Game time runs faster during the long walk so the suite stays short.
const WALK_TIME_SCALE: float = 3.0

var _runner: GdUnitSceneRunner
var _level: SectorLevel
var _player: PlayerController
var _rig: CameraController


func before_test() -> void:
	_runner = scene_runner(SCENE)
	_level = _runner.find_child("SectorLevel") as SectorLevel
	_player = _runner.find_child("Player") as PlayerController
	_rig = _runner.find_child("CameraRig") as CameraController
	_rig.capture_mouse = false
	await _frames(3)
	# The opening dialogue holds the player still: skip it (F4 task 3).
	var talk := _runner.find_child("DialoguePlayer") as DialoguePlayer
	# Past the opening, without Vicaquirao's training (F4 task 12a).
	(_runner.find_child("SliceDirector") as SliceDirector).flow.set_flag(&"skip_training")
	while talk.is_playing():
		talk.advance()
	# Walkability is tested without enemies: the warriors have their own suite.
	for enemy: EnemyController in (
		(_runner.find_child("ArenaController") as ArenaController).alive_enemies()
	):
		enemy.process_mode = Node.PROCESS_MODE_DISABLED
		enemy.visible = false
		enemy.collision_layer = 0


func after_test() -> void:
	Engine.time_scale = 1.0
	Input.action_release(&"move_forward")


func _frames(count: int) -> void:
	for i: int in count:
		await get_tree().physics_frame


## Walks towards a global point; returns true when within `reach` metres (horizontal).
func _walk_to(target: Vector3, reach: float, max_frames: int) -> bool:
	Input.action_press(&"move_forward")
	for i: int in max_frames:
		var to: Vector3 = target - _player.global_position
		to.y = 0.0
		if to.length() < reach:
			return true
		_rig.yaw = atan2(-to.x, -to.z)
		await get_tree().physics_frame
	return false


func test_player_starts_on_the_ground_at_the_lookout() -> void:
	await _frames(10)
	assert_bool(_player.is_on_floor()).is_true()
	var start: Vector3 = _level.marker_position(&"Start")
	assert_float(_player.global_position.distance_to(start)).is_less(1.0)


func test_stairs_go_up_and_down_without_falling() -> void:
	var step: Vector3 = _level.layout.terrace_steps()[0]
	var x: float = _level.layout.path_x_at(step.x)
	var below: Vector3 = _level.to_global_point(Vector2(x, step.x + 5.0))
	var above: Vector3 = _level.to_global_point(Vector2(x, step.x - 3.0))
	_player.respawn(below + Vector3.UP * 0.1, 0.0)
	await _frames(5)
	assert_bool(await _walk_to(above, 0.6, 400)).is_true()
	assert_float(_player.global_position.y).is_greater(above.y - 0.3)
	var airborne: int = 0
	Input.action_press(&"move_forward")
	for i: int in 400:
		var to: Vector3 = below - _player.global_position
		to.y = 0.0
		if to.length() < 0.6:
			break
		_rig.yaw = atan2(-to.x, -to.z)
		await get_tree().physics_frame
		if not _player.is_on_floor():
			airborne += 1
	assert_float(_player.global_position.y).is_less(below.y + 0.3)
	# Ramp colliders: no step-by-step drops (the F1 step left 7 frames in the air).
	assert_int(airborne).is_less_equal(2)


func test_the_whole_path_can_be_walked() -> void:
	Engine.time_scale = WALK_TIME_SCALE
	var points: PackedVector3Array = PackedVector3Array()
	for p: Vector2 in _level.layout.path:
		points.append(_level.to_global_point(p))
	_player.respawn(points[0] + Vector3.UP * 0.1, 0.0)
	await _frames(5)
	for i: int in range(1, points.size()):
		var ok: bool = await _walk_to(points[i], 1.2, 1500)
		(
			assert_bool(ok)
			. override_failure_message(
				"Stuck going to path point %d at %s" % [i, _player.global_position]
			)
			. is_true()
		)
		if not ok:
			return
		# Never below the ground: falling through or off the sector.
		assert_float(_player.global_position.y).is_greater(points[i].y - 2.0)


func test_kit_dressing_is_in_place_and_cheap_to_draw() -> void:
	var sector: Node3D = _level.sector
	var meshes: int = sector.find_children("*", "MeshInstance3D", true, false).size()
	var multis: Array[Node] = sector.find_children("*", "MultiMeshInstance3D", true, false)
	# Vegetation is chunked and culled by distance: it has its own budget (test_vegetation).
	multis = multis.filter(func(n: Node) -> bool: return n.get_parent().name != "Vegetation")
	# One draw call per mesh node (shadows double it): far below the 350 budget.
	assert_int(meshes + multis.size()).is_less(60)
	var rocks: int = 0
	var edge: int = 0
	for node: Node in multis:
		var mm: MultiMesh = (node as MultiMeshInstance3D).multimesh
		if node.name == "PathEdge":
			edge = mm.instance_count
		else:
			rocks += mm.instance_count
	assert_int(rocks).is_greater_equal(int(_level.layout.rock_count * 0.9))
	assert_int(edge).is_greater(200)
	assert_object(sector.get_node_or_null("Corral0")).is_not_null()
	assert_object(sector.get_node_or_null("Channel")).is_not_null()


func test_no_big_rock_inside_the_encounter_zones() -> void:
	# Placement data, not the MultiMesh: headless runs do not keep instance transforms
	# (before this, the check read (0, 0, 0) for every rock and passed by chance).
	var by_size: Array[Array] = SectorDressing.rock_placements(_level.layout)
	assert_int(by_size[1].size() + by_size[2].size()).is_greater(20)
	for size: int in [1, 2]:
		for xf: Transform3D in by_size[size]:
			for e: Vector3 in _level.layout.encounters:
				var d: float = Vector2(xf.origin.x, xf.origin.z).distance_to(Vector2(e.x, e.y))
				assert_float(d).is_greater(e.z)
