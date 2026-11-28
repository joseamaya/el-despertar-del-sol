class_name Prisoner
extends CharacterBody3D
## One person Cusi frees and leads (F10 task 5). Tied, they sit; freed, they walk where
## EscortParty tells them along the navmesh and crouch when told. They take hits from the
## Chancas (their hurtbox is on Cusi's side) and fall when their health runs out. No
## combat, no lock-on: EscortParty decides everything else.

const GRAVITY: float = 9.8
const ACCELERATION: float = 14.0
const TURN_SPEED: float = 8.0

@export var nav_agent: NavigationAgent3D
@export var health: HealthComponent
@export var model: Node3D

var tuning: EscortTuning
var tied: bool = true
var crouched: bool = false

var _desired: Vector3 = Vector3.ZERO
var _anim: AnimationPlayer


func _ready() -> void:
	assert(nav_agent != null and health != null and model != null, "Prisoner: parts.")
	_anim = model.find_child("AnimationPlayer", true, false) as AnimationPlayer


## Sets the values and the look; then the prisoner sits, tied.
func setup(values: EscortTuning) -> void:
	tuning = values
	health.tuning = values.health
	health.reset()
	if values.look != null:
		CharacterOutfit.apply(model, values.look)
	_play(values.tied_clip)


func _physics_process(delta: float) -> void:
	var flat := Vector3(velocity.x, 0.0, velocity.z).move_toward(_desired, ACCELERATION * delta)
	velocity.x = flat.x
	velocity.z = flat.z
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	move_and_slide()
	if flat.length_squared() > 0.01:
		var yaw: float = atan2(flat.x, flat.z)
		rotation.y = lerp_angle(rotation.y, yaw, minf(1.0, TURN_SPEED * delta))


## Freed: on their feet.
func untie() -> void:
	tied = false
	_play(tuning.idle_clip)


## Walks (or jogs, when far) toward `point`; stands still once close enough.
func go_to(point: Vector3) -> void:
	if tied or health.is_dead():
		return
	crouched = false
	var distance: float = Vector2(point.x - global_position.x, point.z - global_position.z).length()
	if distance <= tuning.settle_distance:
		stand()
		return
	nav_agent.target_position = point
	var next: Vector3 = nav_agent.get_next_path_position()
	var direction := Vector3(next.x - global_position.x, 0.0, next.z - global_position.z)
	if direction.length_squared() < 0.0001:
		direction = Vector3(point.x - global_position.x, 0.0, point.z - global_position.z)
	var jog: bool = distance > tuning.jog_beyond
	_desired = direction.normalized() * (tuning.jog_speed if jog else tuning.walk_speed)
	_play(tuning.jog_clip if jog else tuning.walk_clip)


func stand() -> void:
	_desired = Vector3.ZERO
	if not tied and not crouched:
		_play(tuning.idle_clip)


## Down on their heels while a fight is on.
func crouch() -> void:
	if tied or health.is_dead():
		return
	crouched = true
	_desired = Vector3.ZERO
	_play(tuning.crouch_clip)


## Back on their feet at `at` with full health (a retry after a defeat).
func revive(at: Vector3) -> void:
	health.reset()
	crouched = false
	_desired = Vector3.ZERO
	velocity = Vector3.ZERO
	global_position = at
	visible = true
	_play(tuning.tied_clip if tied else tuning.idle_clip)


func current_clip() -> StringName:
	return StringName(_anim.current_animation) if _anim != null else &""


func _play(clip: StringName) -> void:
	if _anim == null or not _anim.has_animation(clip) or _anim.current_animation == clip:
		return
	_anim.get_animation(clip).loop_mode = Animation.LOOP_LINEAR
	_anim.play(clip)
