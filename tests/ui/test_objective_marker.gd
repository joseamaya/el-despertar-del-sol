extends GdUnitTestSuite
## Where to go (F6 task 8): the marker points at the place the current step sends the
## player to, hides while the player is held or fighting, and fades out near the place.

const SCENE: String = "res://scenes/levels/carmenca.tscn"

var _runner: GdUnitSceneRunner
var _slice: SliceDirector
var _marker: ObjectiveMarker
var _player: PlayerController
var _level: SectorLevel
var _talk: DialoguePlayer


func before_test() -> void:
	_runner = scene_runner(SCENE)
	_slice = _runner.find_child("SliceDirector") as SliceDirector
	_marker = _runner.find_child("ObjectiveMarker") as ObjectiveMarker
	_player = _runner.find_child("Player") as PlayerController
	_level = _runner.find_child("SectorLevel") as SectorLevel
	_talk = _runner.find_child("DialoguePlayer") as DialoguePlayer
	(_runner.find_child("CameraRig") as CameraController).capture_mouse = false
	await _frames(5)
	_slice.skip_intro()
	_slice.flow.set_flag(&"skip_training")


func _frames(count: int) -> void:
	for i: int in count:
		await get_tree().physics_frame


func test_hidden_while_the_player_is_held_in_a_talk() -> void:
	assert_bool(_talk.is_playing()).is_true()
	assert_object(_marker.target_position()).is_null()


func test_points_at_the_first_fight_and_shows() -> void:
	while _talk.is_playing():
		_talk.advance()
	await _frames(5)
	assert_int(_slice.flow.current().kind).is_equal(SliceStep.Kind.ENCOUNTER)
	var target: Vector3 = _marker.target_position() as Vector3
	assert_vector(target).is_equal_approx(_level.marker_position(&"Encounter1"), Vector3.ONE * 0.01)
	for i: int in 60:
		await get_tree().process_frame
	assert_bool(_marker.is_showing()).is_true()


func test_fades_out_near_the_place() -> void:
	while _talk.is_playing():
		_talk.advance()
	await _frames(5)
	var target: Vector3 = _marker.target_position() as Vector3
	_player.global_position = target + Vector3(1.0, 0.5, 1.0)
	for i: int in 60:
		await get_tree().process_frame
	assert_bool(_marker.is_showing()).is_false()
