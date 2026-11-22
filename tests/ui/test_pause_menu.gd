extends GdUnitTestSuite
## Integration: the pause menu in Carmenca (F4 task 8). It pauses and resumes, its
## settings page changes the settings (pointed at a test file, never the player's), the
## camera follows the sensitivity, and it does not open over the codex nor on the defeat
## screen, where Start retries.

const SCENE: String = "res://scenes/levels/carmenca.tscn"
const TEST_PATH: String = "user://test_pause_settings.cfg"

var _runner: GdUnitSceneRunner
var _pause: PauseMenu
var _settings: GameSettings
var _saved_path: String
var _saved: Array[float] = []


func before_test() -> void:
	_settings = get_node(^"/root/Settings") as GameSettings
	_saved_path = _settings.path
	_saved = [_settings.volume, _settings.look_sensitivity, _settings.scale_3d]
	_settings.path = TEST_PATH
	_runner = scene_runner(SCENE)
	_pause = _runner.find_child("PauseMenu") as PauseMenu
	(_runner.find_child("CameraRig") as CameraController).capture_mouse = false
	await _frames(5)


func after_test() -> void:
	get_tree().paused = false
	_settings.volume = _saved[0]
	_settings.look_sensitivity = _saved[1]
	_settings.scale_3d = _saved[2]
	_settings.path = _saved_path
	_settings.apply()
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_PATH))


func _frames(count: int) -> void:
	for i: int in count:
		await get_tree().process_frame


func test_pauses_and_resumes() -> void:
	assert_bool(_pause.can_open()).is_true()
	_pause.open()
	assert_bool(_pause.is_open()).is_true()
	assert_bool(get_tree().paused).is_true()
	_pause.close()
	assert_bool(get_tree().paused).is_false()


func test_settings_page_changes_settings_and_the_camera() -> void:
	_pause.open()
	_pause.show_options()
	assert_bool(_pause.is_showing_options()).is_true()
	var slider := _pause.find_child("Sensitivity", true, false) as HSlider
	slider.value = 2.0
	assert_float(_settings.look_sensitivity).is_equal(2.0)
	var rig := _runner.find_child("CameraRig") as CameraController
	assert_float(rig.look_scale).is_equal(2.0)
	(_pause.find_child("Volume", true, false) as HSlider).value = 0.4
	assert_float(_settings.volume).is_equal_approx(0.4, 0.001)
	var scale := _pause.find_child("Scale", true, false) as OptionButton
	assert_int(scale.item_count).is_equal(_settings.defaults.scale_3d_options.size())
	scale.select(2)
	scale.item_selected.emit(2)
	assert_float(_settings.scale_3d).is_equal(1.0)
	_pause.show_main()
	assert_bool(_pause.is_showing_options()).is_false()


func test_not_over_the_codex() -> void:
	var codex := _runner.find_child("CodexScreen") as CodexScreen
	codex.open()
	assert_bool(_pause.can_open()).is_false()
	codex.close()
	assert_bool(_pause.can_open()).is_true()


func test_not_on_the_defeat_screen() -> void:
	var talk := _runner.find_child("DialoguePlayer") as DialoguePlayer
	# Past the opening, without Vicaquirao's training (F4 task 12a).
	(_runner.find_child("SliceDirector") as SliceDirector).flow.set_flag(&"skip_training")
	(_runner.find_child("SliceDirector") as SliceDirector).skip_intro()
	while talk.is_playing():
		talk.advance()
	var player := _runner.find_child("Player") as PlayerController
	var health := player.get_node(^"Health") as HealthComponent
	health.apply_damage(health.get_maximum())
	await _frames(5)
	assert_bool(_pause.can_open()).is_false()


## F5 task 5: the menu says which build this is, for testers' reports.
func test_shows_the_build_version() -> void:
	assert_str(GameVersion.current()).is_equal("0.1.1-slice")
	_pause.open()
	var version := _pause.find_child("Version", true, false) as Label
	assert_object(version).is_not_null()
	assert_str(version.text).contains("0.1.1-slice")
	assert_bool(version.text.contains("PAUSE_")).is_false()
	_pause.close()
