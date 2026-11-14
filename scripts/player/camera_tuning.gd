class_name CameraTuning
extends Resource
## Third-person camera values. Initial values are proposals to tune by playing.
## "Ajustes del jugador" are player preferences (GDD §12.4); they move to the settings
## service when the settings menu exists.

@export_group("Encuadre")
## Distance from the pivot to the camera when nothing is in the way.
@export_range(1.0, 12.0, 0.1, "suffix:m") var distance: float = 4.5
## Pivot height above the target's origin (its feet).
@export_range(0.0, 3.0, 0.05, "suffix:m") var pivot_height: float = 1.6
## Lateral framing offset; positive = player shown left of center (over the right shoulder).
@export_range(-1.5, 1.5, 0.05, "suffix:m") var shoulder_offset: float = 0.4
@export_range(40.0, 100.0, 1.0, "suffix:°") var fov: float = 70.0
## Pitch when the camera starts. Negative looks down at the player.
@export_range(-89.0, 89.0, 1.0, "suffix:°") var initial_pitch_deg: float = -20.0

@export_group("Límites")
@export_range(-89.0, 0.0, 1.0, "suffix:°") var pitch_min_deg: float = -60.0
@export_range(0.0, 89.0, 1.0, "suffix:°") var pitch_max_deg: float = 35.0

@export_group("Seguimiento")
## Exponential follow rate. Higher = tighter, lower = floatier.
@export_range(1.0, 60.0, 0.5) var follow_sharpness: float = 12.0
## Gap kept between the camera and a wall when it is pulled in.
@export_range(0.0, 1.0, 0.05, "suffix:m") var collision_margin: float = 0.2

@export_group("Lock-on")
## How fast the camera turns to frame the locked target. Higher = snappier.
@export_range(1.0, 40.0, 0.5) var lock_turn_sharpness: float = 10.0
## Pitch while locked. Negative looks down at the player and target.
@export_range(-60.0, 20.0, 1.0, "suffix:°") var lock_pitch_deg: float = -15.0

@export_group("Ajustes del jugador")
@export_range(0.01, 1.0, 0.01, "suffix:°/px") var mouse_sensitivity: float = 0.15
@export_range(30.0, 600.0, 5.0, "suffix:°/s") var stick_sensitivity: float = 180.0
@export var invert_x: bool = false
@export var invert_y: bool = false
## Camera shake on impacts. Off for players sensitive to it (GDD §12.4).
@export var shake_enabled: bool = true

@export_group("Sacudida")
## Max sideways/vertical camera offset at full shake.
@export_range(0.0, 1.0, 0.01, "suffix:m") var shake_max_offset: float = 0.12
@export_range(0.0, 10.0, 0.1, "suffix:°") var shake_max_roll_deg: float = 1.5
## How fast shake fades (trauma per second).
@export_range(0.1, 20.0, 0.1, "suffix:/s") var shake_decay: float = 3.0
