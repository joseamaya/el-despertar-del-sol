extends GdUnitTestSuite
## Integration: voices at the lookout (F4). As the family goes down past Cusi (once the
## training is over), two of them tell him what is happening, once each, as a subtitle
## that never stops the game; and Vicaquirao says he and his warriors hold the lookout,
## so Cusi climbs alone.

const SCENE: String = "res://scenes/levels/carmenca.tscn"
const OPENING: String = "res://resources/dialogue/carmenca_opening.tres"
const TIME_SCALE: float = 8.0

var _runner: GdUnitSceneRunner
var _crowd: SectorCrowd
var _line: PassingLine


func before_test() -> void:
	_runner = scene_runner(SCENE)
	_crowd = _runner.find_child("Crowd") as SectorCrowd
	_line = _runner.find_child("PassingLine") as PassingLine
	(_runner.find_child("CameraRig") as CameraController).capture_mouse = false
	await _frames(5)


func after_test() -> void:
	Engine.time_scale = 1.0


func _frames(count: int) -> void:
	for i: int in count:
		await get_tree().physics_frame


func test_the_family_tells_cusi_in_passing_without_stopping_the_game() -> void:
	var said: Array[StringName] = []
	var shown: Array[String] = []
	_crowd.person_spoke.connect(func(_s: StringName, line: StringName) -> void: said.append(line))
	var talk := _runner.find_child("DialoguePlayer") as DialoguePlayer
	# Past the opening, without the training: the first skirmish starts and they set off.
	var slice := _runner.find_child("SliceDirector") as SliceDirector
	slice.flow.set_flag(&"skip_training")
	while talk.is_playing():
		talk.advance()
	await _frames(2)
	assert_bool(_crowd.is_held()).is_false()
	Engine.time_scale = TIME_SCALE
	for i: int in int(80.0 * 60.0 / TIME_SCALE):
		if _line.is_showing() and not shown.has(_line.shown_text()):
			shown.append(_line.shown_text())
		if shown.size() == 2:
			break
		await _frames(1)
	assert_array(said).is_equal([&"BARK_FLEE_1", &"BARK_FLEE_2"])
	assert_int(shown.size()).is_equal(2)
	assert_str(shown[0]).contains(tr(&"BARK_FLEE_1")).contains(tr(&"NAME_COMUNERO"))
	assert_str(shown[1]).contains(tr(&"BARK_FLEE_2")).contains(tr(&"NAME_COMUNERA"))
	# Nobody waited for them: the player was never stopped.
	assert_bool(talk.is_playing()).is_false()
	# Once each, and the subtitle goes away on its own.
	await _frames(int((_crowd.people.line_time + 2.0) * 60.0 / TIME_SCALE))
	assert_int(said.size()).is_equal(2)
	assert_bool(_line.is_showing()).is_false()


func test_vicaquirao_says_they_hold_the_lookout() -> void:
	var opening := load(OPENING) as DialogueScript
	var last: DialogueLine = opening.lines[opening.lines.size() - 1]
	assert_str(String(last.speaker)).is_equal("NAME_VICAQUIRAO")
	assert_str(String(last.text)).is_equal("DLG_OPENING_7")
	assert_str(tr(last.text)).is_not_equal("DLG_OPENING_7")
