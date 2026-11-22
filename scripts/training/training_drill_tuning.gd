class_name TrainingDrillTuning
extends Resource
## Vicaquirao's training at the lookout (F4 task 12a, GDD §5.2): the warrior data he
## spars with (slow blows that do no harm) and how he looks.

@export var data: EnemyData
@export var look: CharacterLook
## Parry drill: after this many plain blocks without a parry, it counts as done, so a
## player who cannot time it is never stuck (F5, build 0.1.1). 0: a parry is required.
@export_range(0, 10, 1) var parry_grace_blocks: int = 3
