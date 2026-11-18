extends GdUnitTestSuite
## Unit: GameSettings keeps volume, camera sensitivity and 3D scale within their limits,
## saves and loads them, and applies volume and 3D scale. Uses its own file: the player's
## real settings are never touched.

const TEST_PATH: String = "user://test_settings.cfg"

var _settings: GameSettings


func before_test() -> void:
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_PATH))
	_settings = auto_free(GameSettings.new()) as GameSettings
	_settings.path = TEST_PATH
	add_child(_settings)


func after_test() -> void:
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_PATH))
	# Put the game's own settings back on the bus and the window.
	(get_node(^"/root/Settings") as GameSettings).apply()


func test_starts_from_the_defaults_without_a_file() -> void:
	var d: SettingsDefaults = _settings.defaults
	assert_float(_settings.volume).is_equal(d.volume)
	assert_float(_settings.look_sensitivity).is_equal(d.look_sensitivity)
	assert_float(_settings.scale_3d).is_equal_approx(0.83, 0.001)


func test_values_stay_within_limits_and_scale_snaps() -> void:
	_settings.set_volume(3.0)
	assert_float(_settings.volume).is_equal(1.0)
	_settings.set_look_sensitivity(99.0)
	assert_float(_settings.look_sensitivity).is_equal(_settings.defaults.look_sensitivity_max)
	_settings.set_look_sensitivity(0.0)
	assert_float(_settings.look_sensitivity).is_equal(_settings.defaults.look_sensitivity_min)
	_settings.set_scale_3d(0.9)
	assert_float(_settings.scale_3d).is_equal_approx(0.83, 0.001)
	_settings.set_scale_3d(0.2)
	assert_float(_settings.scale_3d).is_equal_approx(0.75, 0.001)


func test_saved_settings_come_back_and_are_applied() -> void:
	var told: Array[bool] = [false]
	_settings.changed.connect(func() -> void: told[0] = true)
	_settings.set_volume(0.5)
	_settings.set_look_sensitivity(2.0)
	_settings.set_scale_3d(1.0)
	assert_bool(told[0]).is_true()
	var master: int = AudioServer.get_bus_index(&"Master")
	assert_float(AudioServer.get_bus_volume_db(master)).is_equal_approx(linear_to_db(0.5), 0.01)
	assert_float(get_tree().root.scaling_3d_scale).is_equal_approx(1.0, 0.001)
	var again := auto_free(GameSettings.new()) as GameSettings
	again.path = TEST_PATH
	add_child(again)
	assert_float(again.volume).is_equal(0.5)
	assert_float(again.look_sensitivity).is_equal(2.0)
	assert_float(again.scale_3d).is_equal(1.0)


func test_silence_mutes_the_bus() -> void:
	_settings.set_volume(0.0)
	assert_bool(AudioServer.is_bus_mute(AudioServer.get_bus_index(&"Master"))).is_true()
	_settings.reset_to_defaults()
	assert_bool(AudioServer.is_bus_mute(AudioServer.get_bus_index(&"Master"))).is_false()
