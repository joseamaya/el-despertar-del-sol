class_name SliceAudio
extends Node
## Plays the slice's ambience, music and calls (F4 task 9) from the signals of the slice,
## the arena and the huaca rite: wind all along; music in the acts that have it; the
## pututu when the pass first sees the player, again when it calls its reinforcements
## (F4 task 12b), and whatever sound a step carries; the vision heard through a low-pass
## filter. Owns its players; no system calls it.

const MASTER: StringName = &"Master"
const SILENT_DB: float = -60.0

@export var tuning: SliceAudioTuning
@export var slice: SliceDirector
## Optional: the pututu when a zone first sees the player.
@export var arena: ArenaController
## Optional: the muffled vision.
@export var rite: HuacaRite

var _ambience: AudioStreamPlayer
var _music: AudioStreamPlayer
var _calls: AudioStreamPlayer
var _music_tween: Tween
var _muffle_tween: Tween
var _engaged: bool = false
var _muffled: bool = false


func _ready() -> void:
	assert(tuning != null and slice != null, "SliceAudio: tuning and slice.")
	_ambience = _player("Ambience", &"Ambience", tuning.ambience, tuning.ambience_db, true)
	_music = _player("Music", &"Music", tuning.music, SILENT_DB, true)
	_calls = _player("Calls", &"SFX", null, tuning.pututu_db, false)
	if _ambience.stream != null:
		_ambience.play()
	slice.act_changed.connect(_on_act_changed)
	slice.step_started.connect(_on_step_started)
	if arena != null:
		arena.encounter_started.connect(func() -> void: _engaged = false)
		arena.reinforcements_called.connect(_on_reinforcements_called)
	if rite != null:
		rite.offering_made.connect(_muffle.bind(true).unbind(1))
		rite.rite_finished.connect(_muffle.bind(false))
	_muffle_effect().cutoff_hz = 20000.0


func _exit_tree() -> void:
	# The filter lives on the bus, not in the scene: never leave the game muffled.
	var master: int = AudioServer.get_bus_index(MASTER)
	if master >= 0 and AudioServer.get_bus_effect_count(master) > 0:
		AudioServer.set_bus_effect_enabled(master, 0, false)


func _physics_process(_delta: float) -> void:
	if arena == null or tuning.pututu == null:
		return
	var seen: bool = arena.active_zone == tuning.pututu_zone and arena.is_zone_engaged()
	if seen and not _engaged:
		play_call(tuning.pututu, tuning.pututu_db)
	_engaged = seen or (_engaged and arena.active_zone == tuning.pututu_zone)


func is_music_on() -> bool:
	return _music.playing and _music.volume_db > SILENT_DB + 1.0


func is_muffled() -> bool:
	return _muffled


func last_call() -> AudioStream:
	return _calls.stream


func play_call(stream: AudioStream, db: float) -> void:
	_calls.stream = stream
	_calls.volume_db = db
	_calls.play()


func _on_reinforcements_called(_zone: int) -> void:
	if tuning.pututu != null:
		play_call(tuning.pututu, tuning.pututu_db)


func _on_act_changed(act: SliceStep.Act) -> void:
	if tuning.music == null:
		return
	var wanted: bool = act in tuning.music_acts
	if not wanted and not _music.playing:
		return  # Nothing to fade (an empty tween is an error).
	if _music_tween != null:
		_music_tween.kill()
	_music_tween = create_tween()
	if wanted:
		if not _music.playing:
			_music.volume_db = SILENT_DB
			_music.play()
		_music_tween.tween_property(_music, ^"volume_db", tuning.music_db, tuning.music_fade_in)
	else:
		_music_tween.tween_property(_music, ^"volume_db", SILENT_DB, tuning.music_fade_out)
		_music_tween.tween_callback(_music.stop)


func _on_step_started(step: SliceStep) -> void:
	if step.sound != null:
		play_call(step.sound, tuning.step_sound_db)


func _muffle(on: bool) -> void:
	_muffled = on
	var master: int = AudioServer.get_bus_index(MASTER)
	var effect: AudioEffectLowPassFilter = _muffle_effect()
	if on:
		AudioServer.set_bus_effect_enabled(master, 0, true)
	if _muffle_tween != null:
		_muffle_tween.kill()
	_muffle_tween = create_tween()
	var target: float = tuning.vision_cutoff_hz if on else 20000.0
	_muffle_tween.tween_property(effect, ^"cutoff_hz", target, tuning.vision_muffle_time)
	if not on:
		_muffle_tween.tween_callback(AudioServer.set_bus_effect_enabled.bind(master, 0, false))


func _muffle_effect() -> AudioEffectLowPassFilter:
	var master: int = AudioServer.get_bus_index(MASTER)
	return AudioServer.get_bus_effect(master, 0) as AudioEffectLowPassFilter


func _player(
	node_name: String, bus: StringName, stream: AudioStream, db: float, loop: bool
) -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	player.name = node_name
	player.bus = bus
	player.volume_db = db
	if stream != null:
		player.stream = stream.duplicate()
		if loop and player.stream is AudioStreamOggVorbis:
			(player.stream as AudioStreamOggVorbis).loop = true
	add_child(player)
	return player
