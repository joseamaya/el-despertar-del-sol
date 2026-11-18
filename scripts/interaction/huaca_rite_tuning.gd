class_name HuacaRiteTuning
extends Resource
## Values of an offering at a huaca and its vision (F4 task 4, GDD §8.4, §14.1).

@export_group("Offering")
## Extra maximum stamina for good (GDD §8.4: a small physical improvement).
@export_range(0.0, 50.0, 1.0) var stamina_bonus: float = 10.0
## Clip Cusi plays while leaving the offering, and how long it lasts.
@export var offering_clip: StringName = &"Interact"
@export_range(0.2, 5.0, 0.1, "suffix:s") var offering_time: float = 1.4
## Codex entry the offering unlocks (GDD §8.4), once the vision ends; empty for none.
@export var codex_entry: StringName = &""

@export_group("Vision")
## Fog thickens, the stones stand, everything fades back.
@export_range(0.1, 5.0, 0.1, "suffix:s") var fade_in: float = 1.5
@export_range(0.1, 10.0, 0.1, "suffix:s") var hold: float = 3.0
@export_range(0.1, 5.0, 0.1, "suffix:s") var fade_out: float = 1.5
## Fog density at the peak of the vision (the palette's is the rest value).
@export_range(0.0, 0.2, 0.001) var fog_density: float = 0.06
@export var fog_color: Color = Color(0.82, 0.82, 0.8)
## The far backdrop is drawn without fog: during the vision the camera stops seeing past
## this distance and the fog covers the sky, so the whole horizon goes white.
@export_range(20.0, 500.0, 5.0, "suffix:m") var view_distance: float = 70.0
## Stone figures: how many, how far from the huaca (m), and the angle of the arc they
## stand on, centred downhill over the terraces.
@export_range(1, 12, 1) var figures: int = 6
@export_range(3.0, 40.0, 0.5, "suffix:m") var distance_min: float = 8.0
@export_range(3.0, 40.0, 0.5, "suffix:m") var distance_max: float = 13.0
@export_range(10.0, 180.0, 1.0, "suffix:°") var arc_deg: float = 80.0
@export_range(1.0, 3.0, 0.05, "suffix:m") var figure_height: float = 1.9
@export var figure_color: Color = Color(0.3, 0.3, 0.32)
@export var seed: int = 11
