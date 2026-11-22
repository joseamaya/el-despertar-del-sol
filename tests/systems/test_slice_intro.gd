extends GdUnitTestSuite
## The opening shots of the slice (F5, build 0.1.1): three framed shots with a large
## caption each, the Chancas standing on the terraces in the second; then the first
## conversation. The interact button skips them.

const SCENE: String = "res://scenes/levels/carmenca.tscn"
const TIME_SCALE: float = 4.0

var _runner: GdUnitSceneRunner
var _slice: SliceDirector
var _caption: SliceCaption
var _staging: SliceStaging
var _focus: ViewFocus
var _talk: DialoguePlayer


func before_test() -> void:
	_runner = scene_runner(SCENE)
	_slice = _runner.find_child("SliceDirector") as SliceDirector
	_caption = _runner.find_child("SliceCaption") as SliceCaption
	_staging = _runner.find_child("SliceStaging") as SliceStaging
	_focus = _runner.find_child("ViewFocus") as ViewFocus
	_talk = _runner.find_child("DialoguePlayer") as DialoguePlayer
	(_runner.find_child("CameraRig") as CameraController).capture_mouse = false
	await _frames(5)


func after_test() -> void:
	Engine.time_scale = 1.0


func _frames(count: int) -> void:
	for i: int in count:
		await get_tree().physics_frame


func test_three_shots_then_the_first_conversation() -> void:
	var captions: Array[String] = []
	var staged: Array[int] = []
	Engine.time_scale = TIME_SCALE
	for i: int in 3:
		assert_bool(_slice.is_in_intro()).is_true()
		assert_bool(_caption.is_showing()).is_true()
		assert_bool(_focus.is_focused()).is_true()
		captions.append(_caption.shown_text())
		staged.append(_staging.staged().size())
		var step: SliceStep = _slice.flow.current()
		while _slice.flow.current() == step:
			await _frames(5)
	Engine.time_scale = 1.0
	assert_array(captions).is_equal([tr(&"CTX_SHOT_1"), tr(&"CTX_SHOT_2"), tr(&"CTX_SHOT_3")])
	# Chancas standing in view, only in the second shot.
	assert_array(staged).is_equal([0, _staging.count, 0])
	await _frames(2)
	assert_bool(_slice.is_in_intro()).is_false()
	assert_bool(_caption.is_showing()).is_false()
	assert_bool(_talk.is_playing()).is_true()


func test_staged_warriors_do_nothing() -> void:
	while _staging.staged().is_empty():
		await _frames(10)
	var arena := _runner.find_child("ArenaController") as ArenaController
	for enemy: EnemyController in _staging.staged():
		assert_object(enemy.perception.target).is_null()
	assert_int(arena.alive_enemies().size()).is_equal(0)


func test_the_button_skips_the_shots() -> void:
	assert_bool(_slice.is_in_intro()).is_true()
	var press := InputEventAction.new()
	press.action = &"interact"
	press.pressed = true
	Input.parse_input_event(press)
	await _frames(3)
	var release := InputEventAction.new()
	release.action = &"interact"
	Input.parse_input_event(release)
	await _frames(3)
	assert_bool(_slice.is_in_intro()).is_false()
	assert_bool(_caption.is_showing()).is_false()
	assert_bool(_staging.staged().is_empty()).is_true()
	assert_bool(_talk.is_playing()).is_true()
	# The same press does not also skip the first line.
	assert_str((_runner.find_child("DialogueBox") as DialogueBox).shown_text()).is_equal(
		tr(&"DLG_OPENING_1")
	)
