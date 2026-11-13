class_name CameraController
extends Node3D
## Third-person camera rig: follows `target`, orbits with mouse and right stick,
## and is pulled in by walls through its SpringArm3D. Lock-on comes later (F1, task 5).

const ACTION_LOOK_LEFT: StringName = &"look_left"
const ACTION_LOOK_RIGHT: StringName = &"look_right"
const ACTION_LOOK_UP: StringName = &"look_up"
const ACTION_LOOK_DOWN: StringName = &"look_down"
const ACTION_RELEASE_MOUSE: StringName = &"ui_cancel"

@export var tuning: CameraTuning
## Node to follow (the player). Its collision body is excluded from camera collision.
@export var target: Node3D
@export var spring_arm: SpringArm3D
@export var camera: Camera3D
## Capture the mouse on start and on click; Esc releases it.
@export var capture_mouse: bool = true

## Current orbit, radians. Public so tests and cutscenes can set it.
var yaw: float = 0.0
var pitch: float = 0.0


func _ready() -> void:
	assert(tuning != null, "CameraController needs a CameraTuning resource.")
	assert(target != null, "CameraController needs a target to follow.")
	assert(spring_arm != null and camera != null, "CameraController needs its arm and camera.")
	top_level = true
	pitch = deg_to_rad(tuning.initial_pitch_deg)
	var body: CollisionObject3D = target as CollisionObject3D
	if body != null:
		spring_arm.add_excluded_object(body.get_rid())
	snap_to_target()
	if capture_mouse:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _physics_process(delta: float) -> void:
	tick(delta)


func _unhandled_input(event: InputEvent) -> void:
	var motion: InputEventMouseMotion = event as InputEventMouseMotion
	if motion != null and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		add_look_input(motion.relative)
	elif event.is_action_pressed(ACTION_RELEASE_MOUSE):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif capture_mouse and event is InputEventMouseButton and event.is_pressed():
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


## Mouse motion in pixels. Public so tests can drive it without input events.
func add_look_input(relative: Vector2) -> void:
	_apply(CameraMath.look_from_mouse(relative, tuning))


## Advances the rig: stick look, follow and framing. Called every physics frame.
func tick(delta: float) -> void:
	var stick: Vector2 = Input.get_vector(
		ACTION_LOOK_LEFT, ACTION_LOOK_RIGHT, ACTION_LOOK_UP, ACTION_LOOK_DOWN
	)
	if not stick.is_zero_approx():
		_apply(CameraMath.look_from_stick(stick, delta, tuning))
	global_position = CameraMath.follow(
		global_position, _pivot_position(), tuning.follow_sharpness, delta
	)
	_apply_framing()


## Jumps to the target without smoothing (spawn, respawn, teleports).
func snap_to_target() -> void:
	global_position = _pivot_position()
	_apply_framing()


func _apply(look: Vector2) -> void:
	var orbit: Vector2 = CameraMath.apply_look(Vector2(yaw, pitch), look, tuning)
	yaw = orbit.x
	pitch = orbit.y
	_apply_framing()


func _apply_framing() -> void:
	rotation = Vector3(0.0, yaw, 0.0)
	spring_arm.rotation = Vector3(pitch, 0.0, 0.0)
	spring_arm.spring_length = tuning.distance
	spring_arm.margin = tuning.collision_margin
	camera.h_offset = tuning.shoulder_offset
	camera.fov = tuning.fov


func _pivot_position() -> Vector3:
	return target.global_position + Vector3.UP * tuning.pivot_height
