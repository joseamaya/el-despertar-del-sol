class_name StaminaTuning
extends Resource
## Stamina values (GDD §6.5). Action costs live with each action (attacks, dodge, block,
## sprint), not here.

## Must be > 0. Player: 100.
@export_range(1.0, 500.0, 1.0) var max_stamina: float = 100.0
@export_range(0.0, 200.0, 0.5, "suffix:/s") var regen_per_second: float = 30.0
## Time without spending before regeneration starts.
@export_range(0.0, 5.0, 0.05, "suffix:s") var regen_delay: float = 0.6
