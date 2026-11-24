extends GdUnitTestSuite
## ChapterProgress (F8 task 4): missions open when enough of the ones they require are
## done ("2 of 3"), a level that ends completes its active mission only with the
## mission's flag, flags are kept, and to_dict/from_dict round-trip.


func _mission(
	id: StringName,
	level: StringName,
	requires: Array[StringName] = [],
	count: int = 0,
	flag: StringName = &""
) -> MissionData:
	var m := MissionData.new()
	m.id = id
	m.level = level
	m.requires = requires
	m.requires_count = count
	m.complete_flag = flag
	return m


func _chapter() -> ChapterData:
	var c := ChapterData.new()
	c.id = &"test"
	c.missions = [
		_mission(&"start", &"l_start"),
		_mission(&"a", &"l_a", [&"start"], 0, &"a_won"),
		_mission(&"b", &"l_b", [&"start"]),
		_mission(&"c", &"l_c", [&"start"]),
		_mission(&"show", &"l_show", [&"a", &"b", &"c"], 2),
	]
	return c


func test_only_missions_without_requirements_open_at_first() -> void:
	var p := ChapterProgress.new(_chapter())
	assert_array(p.available()).contains_exactly([&"start"])
	assert_int(p.state(&"a")).is_equal(ChapterProgress.MissionState.LOCKED)
	assert_int(p.state(&"nowhere")).is_equal(ChapterProgress.MissionState.LOCKED)


func test_finishing_the_level_completes_the_active_mission() -> void:
	var p := ChapterProgress.new(_chapter())
	var done: Array[StringName] = []
	p.mission_completed.connect(func(id: StringName) -> void: done.append(id))
	assert_bool(p.start(&"start")).is_true()
	assert_int(p.state(&"start")).is_equal(ChapterProgress.MissionState.ACTIVE)
	assert_str(String(p.finish_level(&"l_start", [&"llamas_freed"]))).is_equal("start")
	assert_array(done).contains_exactly([&"start"])
	assert_bool(p.has_flag(&"llamas_freed")).is_true()
	assert_array(p.available()).contains_exactly([&"a", &"b", &"c"])


func test_a_mission_with_a_flag_needs_it() -> void:
	var p := ChapterProgress.new(_chapter())
	p.complete(&"start")
	p.start(&"a")
	assert_str(String(p.finish_level(&"l_a", []))).is_empty()
	assert_int(p.state(&"a")).is_equal(ChapterProgress.MissionState.ACTIVE)
	assert_str(String(p.finish_level(&"l_a", [&"a_won"]))).is_equal("a")


func test_another_level_does_not_complete_the_mission() -> void:
	var p := ChapterProgress.new(_chapter())
	p.start(&"start")
	assert_str(String(p.finish_level(&"l_b", []))).is_empty()
	assert_bool(p.is_done(&"start")).is_false()


func test_two_of_three_open_the_show_of_force() -> void:
	var p := ChapterProgress.new(_chapter())
	p.complete(&"start")
	p.complete(&"b")
	assert_int(p.state(&"show")).is_equal(ChapterProgress.MissionState.LOCKED)
	p.complete(&"c")
	assert_int(p.state(&"show")).is_equal(ChapterProgress.MissionState.AVAILABLE)


func test_locked_missions_cannot_start_or_complete() -> void:
	var p := ChapterProgress.new(_chapter())
	assert_bool(p.start(&"a")).is_false()
	assert_bool(p.complete(&"a")).is_false()
	assert_bool(p.complete(&"start")).is_true()
	assert_bool(p.complete(&"start")).is_false()


func test_abandon_leaves_the_mission_open() -> void:
	var p := ChapterProgress.new(_chapter())
	p.start(&"start")
	p.abandon()
	assert_str(String(p.active())).is_empty()
	assert_int(p.state(&"start")).is_equal(ChapterProgress.MissionState.AVAILABLE)


func test_round_trips_through_a_dictionary() -> void:
	var p := ChapterProgress.new(_chapter())
	p.complete(&"start")
	p.complete(&"a")
	p.start(&"b")
	p.set_flag(&"prologo_visto")
	var copy := ChapterProgress.new(_chapter())
	copy.from_dict(p.to_dict())
	assert_bool(copy.is_done(&"a")).is_true()
	assert_str(String(copy.active())).is_equal("b")
	assert_bool(copy.has_flag(&"prologo_visto")).is_true()
	assert_dict(copy.to_dict()).is_equal(p.to_dict())


func test_ignores_unknown_entries() -> void:
	var p := ChapterProgress.new(_chapter())
	p.from_dict({"missions": {"ghost": "done", "start": "weird"}, "flags": ["x"]})
	assert_int(p.done_count()).is_equal(0)
	assert_bool(p.has_flag(&"x")).is_true()
