class_name CombatAudio
extends Node3D
## Plays a character's combat sounds from the signals of its components. Every source is
## optional, so the same node serves the player and enemies.

signal sound_played(event: StringName)

const EVENTS: Array[StringName] = [
	&"hit", &"hit_heavy", &"blocked", &"parried", &"evaded", &"telegraph", &"death"
]

@export var sounds: CombatAudioSet
@export var hurtbox: Hurtbox
@export var health: HealthComponent
@export var player_defense: DefenseComponent
@export var guard: EnemyGuard
@export var enemy_combat: EnemyCombat

var last_event: StringName = &""
var _players: Dictionary = {}


func _ready() -> void:
	assert(sounds != null, "CombatAudio needs a CombatAudioSet.")
	for event: StringName in EVENTS:
		var streams: Array[AudioStream] = sounds.get(event)
		if streams.is_empty():
			continue
		var randomizer := AudioStreamRandomizer.new()
		randomizer.random_pitch = 1.0 + sounds.pitch_variation
		for stream: AudioStream in streams:
			randomizer.add_stream(-1, stream)
		var player := AudioStreamPlayer3D.new()
		player.name = "Sfx_%s" % event
		player.stream = randomizer
		player.volume_db = sounds.volume_db
		player.max_distance = sounds.max_distance
		add_child(player)
		_players[event] = player
	if hurtbox != null:
		hurtbox.hit_received.connect(_on_hit)
	if health != null:
		health.died.connect(play.bind(&"death"))
	if player_defense != null:
		player_defense.blocked.connect(_on_event.bind(&"blocked"))
		player_defense.parried.connect(_on_event.bind(&"parried"))
		player_defense.evaded.connect(_on_event.bind(&"evaded"))
	if guard != null:
		guard.blocked.connect(_on_event.bind(&"blocked"))
	if enemy_combat != null:
		enemy_combat.attack_started.connect(_on_attack_started)


## Plays one of the event's variants. Unknown or empty events are ignored.
func play(event: StringName) -> void:
	var player: AudioStreamPlayer3D = _players.get(event) as AudioStreamPlayer3D
	if player == null:
		return
	player.play()
	last_event = event
	sound_played.emit(event)


func has_event(event: StringName) -> bool:
	return _players.has(event)


func _on_hit(info: HitInfo) -> void:
	var heavy: bool = info.posture_damage >= sounds.heavy_threshold or info.unblockable
	play(&"hit_heavy" if heavy and has_event(&"hit_heavy") else &"hit")


func _on_event(_info: HitInfo, event: StringName) -> void:
	play(event)


func _on_attack_started(_data: AttackData) -> void:
	play(&"telegraph")
