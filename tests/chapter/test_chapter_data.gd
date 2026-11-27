extends GdUnitTestSuite
## The Chapter I data (F8 task 4, `docs/capitulo-1.md` §3): every requirement names a
## mission of the chapter, ids are unique, it can be played to the end, and the show of
## force opens with 2 of the 3 Apoyo missions.

const CHAPTER: String = "res://resources/chapters/capitulo_1.tres"


func test_requirements_name_missions_of_the_chapter() -> void:
	var c := load(CHAPTER) as ChapterData
	var ids: Array[StringName] = c.ids()
	for m: MissionData in c.missions:
		assert_int(ids.count(m.id)).is_equal(1)
		assert_str(tr(m.title)).is_not_equal(String(m.title))
		for required: StringName in m.requires:
			assert_bool(ids.has(required)).is_true()


func test_can_be_played_to_the_end() -> void:
	var p := ChapterProgress.new(load(CHAPTER) as ChapterData)
	var steps: int = 0
	while not p.available().is_empty() and steps < 20:
		p.complete(p.available()[0])
		steps += 1
	assert_bool(p.is_done(&"susurpuquio")).is_true()


func test_show_of_force_needs_two_of_three() -> void:
	var p := ChapterProgress.new(load(CHAPTER) as ChapterData)
	for id: StringName in [&"prologo", &"carmenca", &"provisiones"]:
		p.complete(id)
	assert_int(p.state(&"combate_visible")).is_equal(ChapterProgress.MissionState.LOCKED)
	p.complete(&"disputa")
	assert_int(p.state(&"combate_visible")).is_equal(ChapterProgress.MissionState.AVAILABLE)
