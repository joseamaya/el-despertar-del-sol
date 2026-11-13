class_name MovementTuning
extends Resource
## Player locomotion values. Tuned in the .tres, never in code (GDD §6.5, §13.2).
## Initial values are a starting point for playtesting, not design targets.

## Top speed with full stick deflection or keyboard. Partial stick = walk.
@export_range(0.5, 15.0, 0.1, "suffix:m/s") var run_speed: float = 5.0
## Top speed while sprint is held.
@export_range(0.5, 20.0, 0.1, "suffix:m/s") var sprint_speed: float = 7.5
## How fast horizontal velocity reaches the target while there is input.
@export_range(1.0, 200.0, 0.5, "suffix:m/s²") var acceleration: float = 30.0
## How fast horizontal velocity drops to zero when input is released.
@export_range(1.0, 200.0, 0.5, "suffix:m/s²") var deceleration: float = 40.0
## Exponential turn rate toward the move direction. Higher = snappier.
@export_range(1.0, 40.0, 0.5) var turn_sharpness: float = 12.0
## Downward acceleration while airborne.
@export_range(1.0, 60.0, 0.5, "suffix:m/s²") var gravity: float = 20.0
## While locked on, the player keeps facing the target only when moving within this angle
## of it; beyond it (sideways, backwards) it turns to run where it goes.
@export_range(0.0, 180.0, 1.0, "suffix:°") var lock_face_max_angle_deg: float = 50.0
## Stamina spent per second while sprinting (DECISIONS/0007).
@export_range(0.0, 50.0, 0.5, "suffix:/s") var sprint_stamina_per_second: float = 8.0
