class_name ViewFocus
extends Node
## Turns the camera and the player towards a place while a slice step asks for it
## (SliceStep.look_at, F4 task 7: Cusi looks at Cusco at the end). Meanwhile the player
## stands still and the mouse does not move the camera; both come back when a step
## without it starts or the slice ends.

@export var slice: SliceDirector
@export var level: SectorLevel
@export var camera_rig: CameraController
@export var player: PlayerController
## Nodes that read combat input, paused while focused.
@export var frozen: Array[Node] = []
@export_range(0.1, 6.0, 0.1, "suffix:s") var turn_time: float = 2.0

var _focused: bool = false
var _tween: Tween


func _ready() -> void:
	assert(slice != null and level != null, "ViewFocus: slice and level.")
	assert(camera_rig != null and player != null, "ViewFocus: camera and player.")
	slice.step_started.connect(_on_step_started)
	slice.slice_finished.connect(release)


func is_focused() -> bool:
	return _focused


## Turns towards `point` over turn_time, with the camera at `pitch` (negative looks
## down), and holds the player.
func focus(point: Vector3, pitch: float = -0.06) -> void:
	# Again on every step: a conversation lets the player go when it ends.
	PlayerHold.set_held(player, frozen, true)
	camera_rig.set_process_unhandled_input(false)
	_focused = true
	var to: Vector3 = point - player.global_position
	var yaw: float = atan2(-to.x, -to.z)
	if _tween != null:
		_tween.kill()
	_tween = create_tween().set_parallel().set_trans(Tween.TRANS_SINE)
	_tween.set_ease(Tween.EASE_IN_OUT)
	var rig_yaw: float = camera_rig.yaw + wrapf(yaw - camera_rig.yaw, -PI, PI)
	_tween.tween_property(camera_rig, ^"yaw", rig_yaw, turn_time)
	_tween.tween_property(camera_rig, ^"pitch", pitch, turn_time)
	# The player's front is -Z, like the camera's.
	var body_yaw: float = player.rotation.y + wrapf(yaw - player.rotation.y, -PI, PI)
	_tween.tween_property(player, ^"rotation:y", body_yaw, turn_time)


func release() -> void:
	if not _focused:
		return
	_focused = false
	if _tween != null:
		_tween.kill()
	PlayerHold.set_held(player, frozen, false)
	camera_rig.set_process_unhandled_input(true)


func _on_step_started(step: SliceStep) -> void:
	if step.look_at != &"":
		focus(level.marker_position(step.look_at), step.look_pitch)
	else:
		release()
