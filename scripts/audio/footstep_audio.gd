class_name FootstepAudio
extends Node
## Plays the player's footsteps (F4 task 9): one every stride walked on the ground,
## sounding like what is underfoot in the sector layout (the path, the stone stairs of
## the terraces, or grass).

enum Surface { PATH, STONE, GRASS }

## Stairs stretch this far along the slope around a terrace step (z_low): they run up
## from the low side (see the builder's stairs).
const STAIR_BEFORE: float = 1.4
const STAIR_AFTER: float = 0.4

@export var tuning: FootstepTuning
@export var player: CharacterBody3D
@export var level: SectorLevel

var _walked: float = 0.0
var _last: Vector3 = Vector3.ZERO
var _players: Array[AudioStreamPlayer] = []
var _steps: int = 0
var _last_surface: Surface = Surface.GRASS


func _ready() -> void:
	assert(tuning != null and player != null and level != null, "FootstepAudio: parts.")
	for sounds: Array[AudioStream] in [tuning.path, tuning.stone, tuning.grass]:
		var randomizer := AudioStreamRandomizer.new()
		randomizer.random_pitch = 1.0 + tuning.pitch_variation
		for stream: AudioStream in sounds:
			randomizer.add_stream(-1, stream)
		var out := AudioStreamPlayer.new()
		out.bus = &"SFX"
		out.volume_db = tuning.volume_db
		out.stream = randomizer
		add_child(out)
		_players.append(out)
	_last = player.global_position


func _physics_process(_delta: float) -> void:
	var at: Vector3 = player.global_position
	var moved: float = Vector2(at.x - _last.x, at.z - _last.z).length()
	_last = at
	# Teleports and respawns are not steps.
	if not player.is_on_floor() or moved > 2.0:
		return
	_walked += moved
	if _walked >= tuning.stride:
		_walked = 0.0
		_step()


func steps_taken() -> int:
	return _steps


func last_surface() -> Surface:
	return _last_surface


## What is underfoot at (x, z) of the layout. Pure.
static func surface_at(layout: SectorLayout, xz: Vector2, path_margin: float) -> Surface:
	if layout.distance_to_path(xz) > layout.path_width * 0.5 + path_margin:
		return Surface.GRASS
	for s: Vector3 in layout.terrace_steps():
		if xz.y > s.x - STAIR_BEFORE and xz.y < s.x + STAIR_AFTER:
			return Surface.STONE
	return Surface.PATH


func _step() -> void:
	var local: Vector3 = level.sector.to_local(player.global_position)
	_last_surface = surface_at(level.layout, Vector2(local.x, local.z), tuning.path_margin)
	var out: AudioStreamPlayer = _players[_last_surface]
	if (out.stream as AudioStreamRandomizer).streams_count > 0:
		out.play()
	_steps += 1
