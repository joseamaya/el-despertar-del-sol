extends GdUnitTestSuite
## Integration: the people of Carmenca (F4 task 12c). Everyone is placed on the ground
## with their look and clip, nobody collides, casts shadows or can be locked on; the
## family is not there until the first skirmish (after the training), then walks its route
## down past the lookout and leaves once out of sight, while the
## ones who stayed are still there; only those near the camera are drawn and animated.

const SCENE: String = "res://scenes/levels/carmenca.tscn"

var _runner: GdUnitSceneRunner
var _level: SectorLevel
var _crowd: SectorCrowd


func before_test() -> void:
	_runner = scene_runner(SCENE)
	_level = _runner.find_child("SectorLevel") as SectorLevel
	_crowd = _runner.find_child("Crowd") as SectorCrowd
	(_runner.find_child("CameraRig") as CameraController).capture_mouse = false
	await _frames(5)


func after_test() -> void:
	Engine.time_scale = 1.0


func _frames(count: int) -> void:
	for i: int in count:
		await get_tree().physics_frame


func _walkers() -> Array[int]:
	var out: Array[int] = []
	for i: int in _crowd.people.people.size():
		if _crowd.people.people[i].route.size() >= 2:
			out.append(i)
	return out


func test_everyone_is_there_on_the_ground_and_cheap() -> void:
	var people: Array[SectorPerson] = _crowd.people.people
	assert_int(_crowd.count()).is_equal(people.size())
	assert_int(_walkers().size()).is_greater_equal(3)
	for i: int in people.size():
		var body: Node3D = _crowd.body(i)
		var start: Vector2 = people[i].route[0] if i in _walkers() else people[i].at
		var ground: Vector3 = _level.to_global_point(start)
		assert_float(absf(body.global_position.y - ground.y)).is_less(0.6)
		assert_array(body.find_children("*", "CollisionObject3D", true, false)).is_empty()
		for node: Node in body.find_children("*", "GeometryInstance3D", true, false):
			var g := node as GeometryInstance3D
			assert_int(g.cast_shadow).is_equal(GeometryInstance3D.SHADOW_CASTING_SETTING_OFF)
			assert_float(g.visibility_range_end).is_greater(0.0)
		var outfit: Node = body.find_child(CharacterOutfit.PREFIX + "*", true, false)
		assert_object(outfit).override_failure_message("person %d look" % i).is_not_null()
		var anim := body.find_child("AnimationPlayer", true, false) as AnimationPlayer
		var playing: StringName = anim.current_animation
		assert_bool(playing in [people[i].clip, _crowd.people.walk_clip]).is_true()


func test_the_family_walks_down_and_leaves_once_out_of_sight() -> void:
	var walkers: Array[int] = _walkers()
	var first: int = walkers[0]
	var route: PackedVector2Array = _crowd.people.people[first].route
	var start: Vector3 = _crowd.body(first).global_position
	var left: Array[int] = []
	_crowd.person_left.connect(func(i: int) -> void: left.append(i))
	_crowd.set_off()
	Engine.time_scale = 8.0
	await _frames(int(4.0 * 60.0 / 8.0))
	# Under way: moved, and walking.
	var anim := _crowd.body(first).find_child("AnimationPlayer", true, false) as AnimationPlayer
	assert_str(String(anim.current_animation)).is_equal(String(_crowd.people.walk_clip))
	assert_float(_crowd.body(first).global_position.distance_to(start)).is_greater(2.0)
	# Look away from the end of the route, then give them time to get there.
	var away := Camera3D.new()
	_runner.scene().add_child(away)
	var end: Vector3 = _level.to_global_point(route[route.size() - 1])
	away.look_at_from_position(end + Vector3(0, 2, 0), end + (end - start).normalized() * 50.0)
	away.make_current()
	var length: float = 0.0
	for k: int in range(1, route.size()):
		length += route[k].distance_to(route[k - 1])
	var seconds: float = length / _crowd.people.walk_speed + 12.0
	for f: int in int(seconds * 60.0 / 8.0):
		if left.size() == walkers.size():
			break
		await _frames(1)
	left.sort()
	assert_array(left).is_equal(walkers)
	for i: int in _crowd.people.people.size():
		if not i in walkers:
			assert_object(_crowd.body(i)).override_failure_message("stayed %d" % i).is_not_null()


func test_people_cannot_be_locked_on() -> void:
	for i: int in _crowd.count():
		var areas: Array[Node] = _crowd.body(i).find_children("*", "Area3D", true, false)
		assert_array(areas).is_empty()


func test_only_the_people_near_the_camera_are_drawn_and_animated() -> void:
	await _frames(int(SectorCrowd.CULL_INTERVAL * 60.0) + 5)
	var eye: Vector3 = get_viewport().get_camera_3d().global_position
	var near: int = 0
	var far: int = 0
	for i: int in _crowd.count():
		var body: Node3D = _crowd.body(i)
		var close: bool = body.global_position.distance_to(eye) <= _crowd.people.draw_distance
		# The family is not there yet.
		close = close and not (_crowd.is_held() and i in _walkers())
		assert_bool(_crowd.is_active(i)).override_failure_message("person %d" % i).is_equal(close)
		var anim := body.find_child("AnimationPlayer", true, false) as AnimationPlayer
		assert_bool(anim.active).is_equal(close)
		near += 1 if close else 0
		far += 0 if close else 1
	# At the lookout: the loyal warriors are close, the elders down in the houses are not.
	assert_int(near).is_greater(0)
	assert_int(far).is_greater(0)


func test_the_family_comes_only_when_the_first_skirmish_starts() -> void:
	var slice := _runner.find_child("SliceDirector") as SliceDirector
	var talk := _runner.find_child("DialoguePlayer") as DialoguePlayer
	Engine.time_scale = 8.0
	await _frames(int(20.0 * 60.0 / 8.0))
	# Opening (and training): nobody walks, nobody is seen.
	assert_bool(_crowd.is_held()).is_true()
	for i: int in _walkers():
		assert_bool(_crowd.is_active(i)).is_false()
		var start: Vector3 = _level.to_global_point(_crowd.people.people[i].route[0])
		assert_float(_crowd.body(i).global_position.distance_to(start)).is_less(1.0)
	slice.flow.set_flag(&"skip_training")
	slice.skip_intro()
	while talk.is_playing():
		talk.advance()
	await _frames(2)
	assert_int(slice.flow.current().kind).is_equal(SliceStep.Kind.ENCOUNTER)
	assert_int(slice.flow.current().zone).is_equal(_crowd.people.start_zone)
	assert_bool(_crowd.is_held()).is_false()
	var first: int = _walkers()[0]
	var start: Vector3 = _crowd.body(first).global_position
	await _frames(int(3.0 * 60.0 / 8.0))
	assert_float(_crowd.body(first).global_position.distance_to(start)).is_greater(1.0)
