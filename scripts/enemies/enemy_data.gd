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

@export_group("Ataque")
## Picked at random. Telegraph = windup (GDD §6.5: 0.6–0.8 s for a basic enemy).
@export var attacks: Array[AttackData] = []
## Gets this close before swinging.
@export_range(0.5, 6.0, 0.1, "suffix:m") var attack_range: float = 2.0
## The attack's lunge stops this close to the target, so the swing does not pass behind it.
@export_range(0.3, 4.0, 0.05, "suffix:m") var attack_contact_distance: float = 1.3
## Seconds between attacks (random in [min, max]).
@export_range(0.0, 20.0, 0.1, "suffix:s") var attack_cooldown_min: float = 2.0
@export_range(0.0, 20.0, 0.1, "suffix:s") var attack_cooldown_max: float = 3.5
## Without an attack token, retry after this long (GDD §6.6: the rest feint and circle).
@export_range(0.1, 10.0, 0.1, "suffix:s") var token_retry: float = 1.0
## Chance of a feint (quick step in, no swing) when a token is refused.
@export_range(0.0, 1.0, 0.01) var feint_chance: float = 0.4
@export_range(0.0, 4.0, 0.1, "suffix:m") var feint_distance: float = 1.0
@export_range(0.1, 12.0, 0.1, "suffix:m/s") var feint_speed: float = 4.5

@export_group("Distancia (lanza)")
## The lancer (F9 task 10): closer than this, it backs off while circling and steps back
## before striking, so it hits from the edge of its reach. 0 = never (the club).
@export_range(0.0, 6.0, 0.1, "suffix:m") var keep_away_distance: float = 0.0
## Seconds between two back-offs while circling, so it does not just run away.
@export_range(0.0, 10.0, 0.1, "suffix:s") var keep_away_cooldown: float = 2.5
## Longest it steps back before striking anyway (the target keeps following).
@export_range(0.0, 3.0, 0.05, "suffix:s") var keep_away_max_step: float = 0.6

@export_group("Defensa y reacciones")
## Chance of raising the guard after taking a hit (GDD §7.2: occasional block).
@export_range(0.0, 1.0, 0.01) var block_chance: float = 0.35
@export_range(0.1, 5.0, 0.05, "suffix:s") var block_time: float = 1.0
@export_range(10.0, 360.0, 1.0, "suffix:°") var block_arc_deg: float = 120.0
## Fraction of a blocked hit's posture damage the enemy still takes.
@export_range(0.0, 2.0, 0.05) var block_posture_factor: float = 0.5
## Hits with at least this posture damage count as heavy: the enemy backs off.
@export_range(0.0, 200.0, 1.0) var retreat_posture_threshold: float = 20.0
@export_range(0.0, 10.0, 0.1, "suffix:m") var retreat_distance: float = 2.0
@export_range(0.1, 12.0, 0.1, "suffix:m/s") var retreat_speed: float = 4.0
## Played when hit outside an attack.
@export var hit_react_clip: StringName = &"Hit_Chest"
