class_name LockOnTuning
extends Resource
## Lock-on values (GDD §6.2). Initial values are proposals to tune by playing.
## Camera framing while locked lives in CameraTuning.

@export_group("Selección")
## Max distance to acquire a target.
@export_range(2.0, 40.0, 0.5, "suffix:m") var lock_range: float = 15.0
## Max horizontal angle between the camera's view and a candidate to acquire it.
@export_range(10.0, 180.0, 1.0, "suffix:°") var max_pick_angle_deg: float = 60.0
## How much distance weighs against centering when choosing (0 = only angle).
@export_range(0.0, 2.0, 0.05) var distance_weight: float = 0.35

@export_group("Ruptura")
## The lock breaks when the target is farther than this.
@export_range(2.0, 60.0, 0.5, "suffix:m") var break_distance: float = 20.0
## The lock breaks after losing line of sight for this long.
@export_range(0.0, 5.0, 0.05, "suffix:s") var line_of_sight_grace: float = 1.0

@export_group("Cambio de objetivo")
@export_range(0.0, 2.0, 0.05, "suffix:s") var switch_cooldown: float = 0.25
## Right-stick deflection that counts as a flick to switch target.
@export_range(0.1, 1.0, 0.05) var stick_switch_threshold: float = 0.6
## Horizontal mouse travel (pixels) that counts as a flick to switch target.
@export_range(5.0, 400.0, 5.0, "suffix:px") var mouse_switch_threshold: float = 40.0
