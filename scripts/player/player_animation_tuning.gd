class_name PlayerAnimationTuning
extends Resource
## Locomotion animation values. Cycle speeds are measured from the stock clips'
## root motion (UAL1_Standard_RM.glb) so feet match ground speed; the rest is tuning.

@export_group("Velocidad natural de cada ciclo")
## Ground speed of the walk cycle (Walk: 1.3 m in 1.333 s).
@export_range(0.1, 5.0, 0.005, "suffix:m/s") var walk_cycle_speed: float = 0.975
## Ground speed of the jog cycle (Jog_Fwd: 5.0 m in 0.933 s).
@export_range(0.5, 12.0, 0.005, "suffix:m/s") var jog_cycle_speed: float = 5.357
## Ground speed of the sprint cycle (Sprint: 5.5 m in 0.667 s).
@export_range(0.5, 15.0, 0.005, "suffix:m/s") var sprint_cycle_speed: float = 8.25

@export_group("Mezcla")
## How fast the blend follows speed changes. Higher = snappier transitions.
@export_range(1.0, 40.0, 0.5) var blend_sharpness: float = 12.0
## Upper limit for speeding clips up when moving faster than the sprint cycle.
@export_range(1.0, 2.0, 0.05) var max_time_scale: float = 1.3
