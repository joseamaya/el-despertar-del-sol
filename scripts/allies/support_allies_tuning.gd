class_name SupportAlliesTuning
extends Resource
## The comuneros who come to the pass when the family was helped (F4 task 6,
## DECISIONS/0012): who, how many, for which zone and slice flag, and where they appear.

## Built from the chanca warrior scene with this data (no blows that kill).
@export var data: EnemyData
@export_range(0, 4, 1) var count: int = 2
## Encounter zone they come to (1-based) and the slice flag that sends them.
@export_range(1, 10, 1) var zone: int = 3
@export var flag: StringName = &"llamas_freed"
## They appear this far behind the player (downhill, where the player came from).
@export_range(4.0, 40.0, 0.5, "suffix:m") var spawn_behind: float = 12.0
@export_range(0.5, 5.0, 0.1, "suffix:m") var spawn_spread: float = 1.6
## How they look: the comunero's outfit (task 10).
@export var look: CharacterLook
## Banner when they arrive (translation key).
@export var notice: StringName = &"NOTICE_ALLIES"
