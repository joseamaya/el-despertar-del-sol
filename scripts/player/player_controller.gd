class_name PlayerController
extends CharacterBody3D
## Camera-relative locomotion: walk/run by stick deflection, sprint, acceleration and facing.
## Values come from a MovementTuning resource; the reference camera is injected.

const ACTION_MOVE_LEFT: StringName = &"move_left"
const ACTION_MOVE_RIGHT: StringName = &"move_right"
const ACTION_MOVE_FORWARD: StringName = &"move_forward"
const ACTION_MOVE_BACK: StringName = &"move_back"
const ACTION_SPRINT: StringName = &"sprint"

const _FACING_MIN_SQ: float = 0.0001

@export var tuning: MovementTuning
## Camera whose yaw defines "forward". Without one, world -Z is forward.
@export var camera: Camera3D

## Last move input read, x = right, y = back. Exposed for debugging and animation later.
var move_input: Vector2 = Vector2.ZERO
var is_sprinting: bool = false

## When set (lock-on), the player keeps facing it and circles it instead of turning
## toward the move direction.
var _face_target: Node3D


func _ready() -> void:
	assert(tuning != null, "PlayerController needs a MovementTuning resource.")


func _physics_process(delta: float) -> void:
	_read_input()
	var reference_basis: Basis = camera.global_basis if camera != null else Basis.IDENTITY
	var direction: Vector3 = LocomotionMath.camera_relative_direction(move_input, reference_basis)
	var target: Vector3 = LocomotionMath.target_velocity(direction, is_sprinting, tuning)

	velocity = LocomotionMath.approach_horizontal(
		velocity, target, tuning.acceleration, tuning.deceleration, delta
	)
	if not is_on_floor():
		velocity.y -= tuning.gravity * delta
	move_and_slide()

	if _face_target != null and not is_instance_valid(_face_target):
		_face_target = null
	var facing: Vector3 = direction
	if _face_target != null:
		facing = _face_target.global_position - global_position
		facing.y = 0.0
	if facing.length_squared() > _FACING_MIN_SQ:
		var target_yaw: float = LocomotionMath.yaw_from_direction(facing)
		rotation.y = LocomotionMath.smooth_yaw(rotation.y, target_yaw, tuning.turn_sharpness, delta)


## Keeps facing `target` (connect LockOnController.target_locked / target_switched).
func set_face_target(target: Node3D) -> void:
	_face_target = target


## Back to facing the move direction (connect LockOnController.target_released).
func release_face_target(_reason: int = 0) -> void:
	_face_target = null


## Horizontal speed in m/s, ignoring falling.
func get_horizontal_speed() -> float:
	return Vector2(velocity.x, velocity.z).length()


func _read_input() -> void:
	move_input = Input.get_vector(
		ACTION_MOVE_LEFT, ACTION_MOVE_RIGHT, ACTION_MOVE_FORWARD, ACTION_MOVE_BACK
	)
	is_sprinting = Input.is_action_pressed(ACTION_SPRINT) and not move_input.is_zero_approx()
