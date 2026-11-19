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
## How near Cusi someone must come to say their line.
@export_range(2.0, 40.0, 0.5, "suffix:m") var talk_radius: float = 12.0
## Seconds a line stays on screen.
@export_range(1.0, 15.0, 0.5, "suffix:s") var line_time: float = 4.5
## The ones who walk set off when the slice starts the encounter of this zone (after
## Vicaquirao's training, so they are noticed); until then they are not there. 0: they
## set off as soon as the sector is built.
@export_range(0, 10, 1) var start_zone: int = 0
