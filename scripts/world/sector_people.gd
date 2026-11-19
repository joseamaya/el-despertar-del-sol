class_name SectorPeople
extends Resource
## The people of a sector who have no part in the story (F4 task 12c) and how they are
## drawn: no shadows, and only up close.

@export var people: Array[SectorPerson] = []
@export var walk_clip: StringName = &"Walk"
## Walking speed matching the walk clip.
@export_range(0.5, 3.0, 0.05, "suffix:m/s") var walk_speed: float = 1.25
## Beyond this distance they are not drawn.
@export_range(10.0, 200.0, 5.0, "suffix:m") var draw_distance: float = 70.0
