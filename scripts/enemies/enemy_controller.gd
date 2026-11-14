class_name EnemyController
extends CharacterBody3D
## Enemy body: moves along the navmesh or around its target and turns smoothly. States
## (StateMachine children) decide what to do each frame through this API.

const ACCELERATION: float = 20.0
const GRAVITY: float = 20.0
const ARRIVE_DISTANCE: float = 0.4

@export var data: EnemyData
@export var nav_agent: NavigationAgent3D
@export var perception: PerceptionComponent
@export var health: HealthComponent
@export var posture: PostureComponent
@export var state_machine: StateMachine
## Shown while alerted ("!"), like a telegraph (GDD §12.4).
@export var alert_marker: Node3D
## Optional: plays the death and hit-react clips.
@export var animator: CharacterAnimator
## Optional parts for fighting (F2 task 8).
@export var combat: EnemyCombat
@export var guard: EnemyGuard
@export var hurtbox: Hurtbox
## Patrol route in world space. Empty: stands guard at home.
@export var patrol_points: Array[Vector3] = []

var home_position: Vector3 = Vector3.ZERO
var _desired: Vector3 = Vector3.ZERO
var _face_point: Vector3 = Vector3.ZERO
var _has_face_point: bool = false
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	assert(data != null and nav_agent != null, "EnemyController needs data and nav agent.")
	assert(perception != null and state_machine != null, "EnemyController needs its parts.")
	home_position = global_position
	show_alert(false)
	if health != null:
		health.died.connect(_on_died)
	if posture != null:
		posture.posture_broken.connect(_on_posture_broken)
	if hurtbox != null:
		hurtbox.hit_received.connect(_on_hit_received)


func _physics_process(delta: float) -> void:
	var flat := Vector3(velocity.x, 0.0, velocity.z)
	flat = flat.move_toward(_desired, ACCELERATION * delta)
	velocity.x = flat.x
	velocity.z = flat.z
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	move_and_slide()
	var look: Vector3 = (_face_point - global_position) if _has_face_point else _desired
	look.y = 0.0
	if look.length_squared() > 0.0001:
		var yaw: float = LocomotionMath.yaw_from_direction(look)
		rotation.y = LocomotionMath.smooth_yaw(rotation.y, yaw, data.turn_sharpness, delta)


## Walks or runs toward `point` along the navmesh. Returns true once there (and stops).
func move_to(point: Vector3, speed: float) -> bool:
	if _flat_distance(point) <= ARRIVE_DISTANCE:
		stop()
		return true
	nav_agent.target_position = point
	var next: Vector3 = nav_agent.get_next_path_position()
	var direction := Vector3(next.x - global_position.x, 0.0, next.z - global_position.z)
	if direction.length_squared() < 0.0001:
		direction = Vector3(point.x - global_position.x, 0.0, point.z - global_position.z)
	_desired = direction.normalized() * speed
	return false


## Circles `center` at `radius`, clockwise (side 1) or counter-clockwise (-1).
func strafe_around(center: Vector3, radius: float, side: int, speed: float) -> void:
	var to_center := Vector3(center.x - global_position.x, 0.0, center.z - global_position.z)
	var distance: float = to_center.length()
	if distance < 0.001:
		stop()
		return
	var radial: Vector3 = to_center / distance
	var tangent: Vector3 = radial.cross(Vector3.UP) * float(side)
	var correction: Vector3 = radial * clampf(distance - radius, -1.0, 1.0)
	_desired = (tangent + correction).normalized() * speed


func stop() -> void:
	_desired = Vector3.ZERO


## Moves straight ahead (attack lunge, which keeps the facing).
func push_forward(speed: float) -> void:
	var forward: Vector3 = global_basis * Vector3.FORWARD
	forward.y = 0.0
	_desired = forward.normalized() * speed


## Moves in a fixed world direction (e.g. backing off).
func move_direction(direction: Vector3, speed: float) -> void:
	var flat := Vector3(direction.x, 0.0, direction.z)
	_desired = flat.normalized() * speed if flat.length_squared() > 0.0001 else Vector3.ZERO


## Keeps facing `point` regardless of movement (e.g. the target while circling).
func face(point: Vector3) -> void:
	_face_point = point
	_has_face_point = true


func clear_face() -> void:
	_has_face_point = false


func show_alert(on: bool) -> void:
	if alert_marker != null:
		alert_marker.visible = on


func distance_to(point: Vector3) -> float:
	return _flat_distance(point)


func get_horizontal_speed() -> float:
	return Vector2(velocity.x, velocity.z).length()


func is_dead() -> bool:
	return health != null and health.is_dead()


func _flat_distance(point: Vector3) -> float:
	return Vector2(point.x - global_position.x, point.z - global_position.z).length()


func _on_died() -> void:
	state_machine.transition_to(&"dead")


## Reacts to a landed hit: heavy hits make it back off; otherwise it may raise its guard.
## While attacking it does not flinch (the attack goes on).
func _on_hit_received(info: HitInfo) -> void:
	if is_dead() or (posture != null and posture.is_broken()):
		return
	if combat != null and combat.is_attacking():
		return
	if animator != null:
		animator.play_attack(data.hit_react_clip, 1.0)
	if not perception.has_target():
		return
	if info.posture_damage >= data.retreat_posture_threshold:
		state_machine.transition_to(&"retreat")
	elif guard != null and _rng.randf() < data.block_chance:
		state_machine.transition_to(&"block")


func _on_posture_broken() -> void:
	if not is_dead():
		state_machine.transition_to(&"stagger")
