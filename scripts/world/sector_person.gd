class_name SectorPerson
extends Resource
## Someone of Carmenca who has no part in the story (F4 task 12c): they stand, sit or
## kneel at a point of the layout, or walk a route and leave. No dialogue, no AI.

## Where they stand (x, z of the layout), unless they walk a route.
@export var at: Vector2 = Vector2.ZERO
## Facing, in degrees (0: towards +Z, downhill).
@export_range(-180.0, 180.0, 1.0, "suffix:°") var yaw_deg: float = 0.0
## Looping clip while standing (Idle, Sitting_Idle, Fixing_Kneeling…).
@export var clip: StringName = &"Idle"
@export var look: CharacterLook
## Children are smaller.
@export_range(0.5, 1.2, 0.05) var scale: float = 1.0
## If set, they walk these points (x, z) from the start of the slice, then go: they
## vanish the first time the camera does not see them.
@export var route: PackedVector2Array = PackedVector2Array()
## Seconds before they set off (a family walks in a line).
@export_range(0.0, 30.0, 0.1, "suffix:s") var delay: float = 0.0
## Height above the ground (a seat).
@export_range(0.0, 1.0, 0.01, "suffix:m") var lift: float = 0.0
## What they say once, in passing, when they first come near Cusi (translation keys).
@export var speaker: StringName = &""
@export var line: StringName = &""
