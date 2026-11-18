class_name FootstepTuning
extends Resource
## Cusi's footsteps (F4 task 9): one every `stride` metres walked on the ground, from the
## set of the surface underfoot.

@export var path: Array[AudioStream] = []
@export var stone: Array[AudioStream] = []
@export var grass: Array[AudioStream] = []
@export_range(0.3, 4.0, 0.05, "suffix:m") var stride: float = 1.4
@export_range(-40.0, 6.0, 0.5, "suffix:dB") var volume_db: float = -10.0
@export_range(0.0, 0.5, 0.01) var pitch_variation: float = 0.1
## The path counts this far beyond its half width.
@export_range(0.0, 2.0, 0.05, "suffix:m") var path_margin: float = 0.3
