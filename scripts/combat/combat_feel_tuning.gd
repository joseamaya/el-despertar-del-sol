class_name CombatFeelTuning
extends Resource
## Game-feel values for hits (GDD §6.5). Task 11 adds camera shake and flashes here.

@export_group("Hitstop")
## Real time the game stays frozen on impact (GDD §6.5: 0.05–0.08 s).
@export_range(0.0, 0.3, 0.005, "suffix:s") var hitstop_duration: float = 0.06
## Time scale during hitstop. 0 = full freeze.
@export_range(0.0, 1.0, 0.01) var hitstop_time_scale: float = 0.05
## Longer freeze for the big moments.
@export_range(0.0, 0.5, 0.005, "suffix:s") var parry_hitstop: float = 0.1
@export_range(0.0, 0.5, 0.005, "suffix:s") var execution_hitstop: float = 0.15

@export_group("Sacudida de cámara (0–1)")
@export_range(0.0, 1.0, 0.01) var shake_on_hurt: float = 0.45
@export_range(0.0, 1.0, 0.01) var shake_on_heavy_hit: float = 0.3
@export_range(0.0, 1.0, 0.01) var shake_on_parry: float = 0.25
@export_range(0.0, 1.0, 0.01) var shake_on_execution: float = 0.5

@export_group("Destello de parry")
@export var parry_flash_color: Color = Color(1.0, 0.92, 0.6)
@export_range(0.05, 2.0, 0.05, "suffix:m") var parry_flash_size: float = 0.7
@export_range(0.02, 1.0, 0.01, "suffix:s") var parry_flash_time: float = 0.14
@export_group("Destello de bloqueo")
## F6 task 4: a blocked blow had only a sound, and players did not notice they blocked.
@export var block_flash_color: Color = Color(0.78, 0.88, 1.0)
@export_range(0.05, 2.0, 0.05, "suffix:m") var block_flash_size: float = 0.9
@export_range(0.02, 1.0, 0.01, "suffix:s") var block_flash_time: float = 0.12
## Sparks thrown from the impact, and how far they fly.
@export_range(0, 16, 1) var block_sparks: int = 7
@export_range(0.05, 2.0, 0.05, "suffix:m") var block_spark_reach: float = 0.9
@export_range(0.0, 1.0, 0.01) var shake_on_block: float = 0.08

@export_group("Impactos")
## Hits with at least this posture damage count as heavy for feedback.
@export_range(0.0, 200.0, 1.0) var heavy_threshold: float = 20.0
