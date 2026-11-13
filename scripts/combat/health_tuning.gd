class_name HealthTuning
extends Resource
## Health values for one kind of character (GDD §6.4, §6.5). One .tres per kind.

## Must be > 0. Player: 100 (GDD §6.5).
@export_range(1.0, 2000.0, 1.0) var max_health: float = 100.0
