class_name CombatAudioSet
extends Resource
## Sounds for one kind of character's combat events (GDD §11.2). Each list holds variants;
## one is picked at random with a little pitch variation so repeats do not sound robotic.

@export var hit: Array[AudioStream] = []
@export var hit_heavy: Array[AudioStream] = []
@export var blocked: Array[AudioStream] = []
@export var parried: Array[AudioStream] = []
@export var evaded: Array[AudioStream] = []
## Audible attack warning at the start of the windup (GDD §12.4).
@export var telegraph: Array[AudioStream] = []
@export var death: Array[AudioStream] = []

## Hits with at least this posture damage use `hit_heavy`.
@export_range(0.0, 200.0, 1.0) var heavy_threshold: float = 20.0
@export_range(-40.0, 12.0, 0.5, "suffix:dB") var volume_db: float = 0.0
@export_range(0.0, 0.5, 0.01) var pitch_variation: float = 0.08
@export_range(1.0, 100.0, 1.0, "suffix:m") var max_distance: float = 30.0
