extends GdUnitTestSuite
## Integration: the slice's sound in Carmenca (F4 task 9). Wind from the start; music in
## the opening that fades with the exploration; the pututu when the pass sees the player;
## the vision heard muffled and then clear; every audio file is registered with its
## licence.

const SCENE: String = "res://scenes/levels/carmenca.tscn"
const SOURCES: String = "res://docs/ASSET_SOURCES.md"
const AUDIO_DIR: String = "res://assets/audio"

var _runner: GdUnitSceneRunner
var _audio: SliceAudio
var _arena: ArenaController
var _level: SectorLevel
var _player: PlayerController


func before_test() -> void:
	_runner = scene_runner(SCENE)
	_audio = _runner.find_child("SliceAudio") as SliceAudio
	_arena = _runner.find_child("ArenaController") as ArenaController
	_level = _runner.find_child("SectorLevel") as SectorLevel
	_player = _runner.find_child("Player") as PlayerController
	(_runner.find_child("CameraRig") as CameraController).capture_mouse = false
	await _frames(10)


func after_test() -> void:
	Engine.time_scale = 1.0


func _frames(count: int) -> void:
	for i: int in count:
		await get_tree().physics_frame


func _skip_opening() -> void:
	var talk := _runner.find_child("DialoguePlayer") as DialoguePlayer
	# Past the opening, without Vicaquirao's training (F4 task 12a).
	(_runner.find_child("SliceDirector") as SliceDirector).flow.set_flag(&"skip_training")
	(_runner.find_child("SliceDirector") as SliceDirector).skip_intro()
	while talk.is_playing():
		talk.advance()
	await _frames(2)


func test_buses_wind_and_opening_music() -> void:
	for bus: StringName in [&"Music", &"Ambience", &"SFX"]:
		assert_int(AudioServer.get_bus_index(bus)).override_failure_message(bus).is_greater(0)
	assert_bool((_audio.get_node(^"Ambience") as AudioStreamPlayer).playing).is_true()
	await _frames(int(_audio.tuning.music_fade_in * 60.0) + 10)
	assert_bool(_audio.is_music_on()).is_true()
	await _skip_opening()
	Engine.time_scale = 4.0
	await _frames(int(_audio.tuning.music_fade_out * 60.0 / 4.0) + 20)
	assert_bool(_audio.is_music_on()).is_false()


func test_pututu_when_the_pass_sees_the_player() -> void:
	await _skip_opening()
	assert_object(_audio.last_call()).is_null()
	Engine.time_scale = 2.0
	_arena.start_zone(_audio.tuning.pututu_zone)
	var zone: Vector3 = _level.layout.encounters[_audio.tuning.pututu_zone - 1]
	_player.respawn(_level.to_global_point(Vector2(zone.x, zone.y + 6.0)) + Vector3.UP * 0.1, 0.0)
	for i: int in 400:
		if _arena.is_zone_engaged():
			break
		await _frames(1)
	await _frames(3)
	assert_object(_audio.last_call()).is_same(_audio.tuning.pututu)


func test_pututu_again_when_the_pass_calls_reinforcements() -> void:
	await _skip_opening()
	var zone: int = _audio.tuning.pututu_zone
	_arena.start_zone(zone)
	await _frames(2)
	assert_int(_arena.wave_size(zone)).is_greater(0)
	_audio.play_call(null, 0.0)
	for enemy: EnemyController in _arena.alive_enemies():
		enemy.health.apply_damage(enemy.health.get_maximum())
	await _frames(3)
	assert_bool(_arena.is_wave_pending()).is_true()
	assert_object(_audio.last_call()).is_same(_audio.tuning.pututu)


func test_the_vision_is_heard_muffled_then_clear() -> void:
	var rite := _runner.find_child("HuacaRite") as HuacaRite
	var master: int = AudioServer.get_bus_index(&"Master")
	var filter := AudioServer.get_bus_effect(master, 0) as AudioEffectLowPassFilter
	rite.offering_made.emit(&"Huaca")
	await _frames(int(_audio.tuning.vision_muffle_time * 60.0) + 10)
	assert_bool(_audio.is_muffled()).is_true()
	assert_bool(AudioServer.is_bus_effect_enabled(master, 0)).is_true()
	assert_float(filter.cutoff_hz).is_equal_approx(_audio.tuning.vision_cutoff_hz, 1.0)
	rite.rite_finished.emit()
	await _frames(int(_audio.tuning.vision_muffle_time * 60.0) + 10)
	assert_bool(_audio.is_muffled()).is_false()
	assert_bool(AudioServer.is_bus_effect_enabled(master, 0)).is_false()


func test_the_ending_carries_the_far_pututus() -> void:
	var seq := load("res://resources/slice/carmenca_slice.tres") as SliceSequence
	var with_sound: Array[SliceStep] = []
	for s: SliceStep in seq.steps:
		if s.sound != null:
			with_sound.append(s)
	assert_int(with_sound.size()).is_equal(1)
	assert_str(with_sound[0].look_at).is_equal("CuscoView")


func test_every_audio_file_is_registered() -> void:
	var sources: String = FileAccess.get_file_as_string(SOURCES)
	var dirs: Array[String] = [AUDIO_DIR]
	while not dirs.is_empty():
		var dir: String = dirs.pop_back()
		for sub: String in DirAccess.get_directories_at(dir):
			dirs.append(dir.path_join(sub))
		var files: PackedStringArray = DirAccess.get_files_at(dir)
		for name: String in files:
			if name.ends_with(".ogg") or name.ends_with(".wav"):
				var folder: String = dir.trim_prefix("res://")
				assert_bool(sources.contains(folder)).override_failure_message(folder).is_true()


## F10 task 3: a silent act while no music plays has nothing to fade, so it starts no tween
## (an empty one is an engine error; the mission sketch goes straight to such an act).
func test_a_silent_act_without_music_starts_no_fade() -> void:
	await _skip_opening()
	Engine.time_scale = 4.0
	await _frames(int(_audio.tuning.music_fade_out * 60.0 / 4.0) + 20)
	assert_bool(_audio.is_music_on()).is_false()
	var before: int = get_tree().get_processed_tweens().size()
	var slice := _runner.find_child("SliceDirector") as SliceDirector
	slice.act_changed.emit(SliceStep.Act.COMBAT)
	assert_int(get_tree().get_processed_tweens().size()).is_equal(before)
