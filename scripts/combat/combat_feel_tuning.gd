class_name CombatFeelTuning
extends Resource
## Game-feel values for hits (GDD §6.5). Task 11 adds camera shake and flashes here.

@export_group("Hitstop")
## Real time the game stays frozen on impact (GDD §6.5: 0.05–0.08 s).
@export_range(0.0, 0.3, 0.005, "suffix:s") var hitstop_duration: float = 0.06
## Time scale during hitstop. 0 = full freeze.
@export_range(0.0, 1.0, 0.01) var hitstop_time_scale: float = 0.05
