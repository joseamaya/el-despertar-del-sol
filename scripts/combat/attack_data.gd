class_name AttackData
extends Resource
## One attack as data (GDD §6.3–6.5). Phase times are in CLIP seconds, measured on the
## animation (when the hand moves fastest); `clip_speed` scales them to real time, so
## changing the playback speed keeps hits in sync with the animation.

@export var id: StringName = &""

@export_group("Efecto")
@export_range(0.0, 200.0, 0.5) var damage: float = 18.0
@export_range(0.0, 200.0, 0.5) var posture_damage: float = 10.0
## Stamina cost (GDD §6.5: light 12, heavy 25). Attacks allow partial stamina (0007).
@export_range(0.0, 100.0, 0.5) var stamina_cost: float = 12.0

@export_group("Animación")
@export var clip: StringName = &"Sword_Attack"
@export_range(0.1, 3.0, 0.05) var clip_speed: float = 1.0
## A thrust drawn by ThrustPose over the clip (F9 task 8: the free pack has no spear
## thrust, `docs/capitulo-1.md` §7.5). The clip then only carries the body.
@export var thrust: bool = false

@export_group("Fases (segundos del clip)")
## End of anticipation: the hitbox turns on here.
@export_range(0.0, 3.0, 0.01, "suffix:s") var windup_end: float = 0.3
## End of the active window: the hitbox turns off here.
@export_range(0.0, 3.0, 0.01, "suffix:s") var active_end: float = 0.5
## End of recovery: the attack is over and control returns.
@export_range(0.0, 5.0, 0.01, "suffix:s") var recovery_end: float = 1.0
## From here a buffered press starts the next attack of the chain.
@export_range(0.0, 5.0, 0.01, "suffix:s") var chain_from: float = 0.6

@export_group("Movimiento")
## Forward step during windup and active phases.
@export_range(0.0, 5.0, 0.05, "suffix:m") var lunge_distance: float = 0.5

@export_group("Ejecución")
## Only for the execution attack: max distance to a target with broken posture.
@export_range(0.0, 5.0, 0.05, "suffix:m") var execution_range: float = 0.0
## Only for the execution attack: the target must be inside this frontal arc.
@export_range(10.0, 360.0, 1.0, "suffix:°") var execution_arc_deg: float = 120.0
