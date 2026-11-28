class_name EscortTuning
extends Resource
## Values of the people Cusi frees and leads (F10 task 5, mission B's prisoners).

## Their health: more than Cusi's, so guarding them is not a chore (design §4).
@export var health: HealthTuning
@export var look: CharacterLook

@export_group("Following")
## How far behind Cusi they walk, and how far apart from each other.
@export_range(0.5, 8.0, 0.1, "suffix:m") var follow_distance: float = 2.5
@export_range(0.5, 4.0, 0.1, "suffix:m") var spacing: float = 1.4
## Closer than this to their place behind Cusi they stand still.
@export_range(0.1, 3.0, 0.05, "suffix:m") var settle_distance: float = 0.8
@export_range(0.5, 6.0, 0.1, "suffix:m/s") var walk_speed: float = 1.8
@export_range(1.0, 8.0, 0.1, "suffix:m/s") var jog_speed: float = 4.2
## Farther than this from their place they jog instead of walking.
@export_range(1.0, 20.0, 0.5, "suffix:m") var jog_beyond: float = 5.0

@export_group("Danger")
## While Cusi is within this distance of a prisoner, the Chancas leave them alone.
@export_range(1.0, 30.0, 0.5, "suffix:m") var protect_radius: float = 8.0
## A Chanca this close to an unguarded prisoner goes for them.
@export_range(1.0, 30.0, 0.5, "suffix:m") var threat_radius: float = 6.0

@export_group("Clips")
@export var tied_clip: StringName = &"Sitting_Idle"
@export var idle_clip: StringName = &"Idle"
@export var walk_clip: StringName = &"Walk"
@export var jog_clip: StringName = &"Jog_Fwd"
@export var crouch_clip: StringName = &"Crouch_Idle"
