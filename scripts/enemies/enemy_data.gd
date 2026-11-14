class_name EnemyData
extends Resource
## One kind of enemy as data (GDD §7.1: a new enemy is a new Resource plus animations).
## Initial values are proposals to tune by playing.

@export var display_name: String = ""
@export var health: HealthTuning
@export var posture: PostureTuning

@export_group("Percepción")
@export_range(1.0, 60.0, 0.5, "suffix:m") var view_distance: float = 14.0
## Full width of the view cone.
@export_range(10.0, 360.0, 1.0, "suffix:°") var view_angle_deg: float = 110.0
## Heard within this radius whatever the direction (GDD §7.1).
@export_range(0.0, 30.0, 0.5, "suffix:m") var hearing_radius: float = 5.0
@export_range(0.5, 2.5, 0.05, "suffix:m") var eye_height: float = 1.6
## Unsensed for this long, the target is lost and the enemy goes home.
@export_range(0.5, 30.0, 0.5, "suffix:s") var lose_target_time: float = 4.0
## Reaction time between noticing the target and chasing it (shows the "!").
@export_range(0.0, 3.0, 0.05, "suffix:s") var alert_time: float = 0.8

@export_group("Movimiento")
@export_range(0.1, 10.0, 0.1, "suffix:m/s") var walk_speed: float = 1.6
@export_range(0.1, 12.0, 0.1, "suffix:m/s") var run_speed: float = 4.2
@export_range(0.1, 10.0, 0.1, "suffix:m/s") var strafe_speed: float = 1.8
@export_range(1.0, 40.0, 0.5) var turn_sharpness: float = 8.0
@export_range(0.0, 10.0, 0.1, "suffix:s") var patrol_wait: float = 1.5

@export_group("Distancias de combate")
## Circles the target at this distance (attacks come from here in F2 task 8).
@export_range(0.5, 15.0, 0.1, "suffix:m") var engage_distance: float = 3.5
## Seconds between changes of circling direction (random in [min, max]).
@export_range(0.2, 10.0, 0.1, "suffix:s") var strafe_switch_min: float = 1.5
@export_range(0.2, 10.0, 0.1, "suffix:s") var strafe_switch_max: float = 3.0
## How long the body stays before disappearing after death.
@export_range(0.0, 10.0, 0.1, "suffix:s") var corpse_time: float = 1.5
