class_name SectorNpc
extends Node3D
## A character who stands at a layout marker and idles (F4 task 3): Vicaquirao at the
## lookout. No AI: the slice decides when they speak. Their look comes in task 10.

@export var level: SectorLevel
## Layout marker to stand on, facing where the marker faces (markers face downhill).
@export var marker: StringName = &"Mentor"
## Optional: someone to turn towards once placed (who they talk to). Otherwise they face
## where the marker faces.
@export var face: Node3D
## Looping clip of the model's AnimationPlayer.
@export var idle_clip: StringName = &"Idle_Talking"
## Optional: how they look (F4 task 10), applied to their child model.
@export var look: CharacterLook


func _ready() -> void:
	assert(level != null, "SectorNpc needs the level.")
	if look != null:
		var model := find_child("Model", false, false) as Node3D
		if model != null:
			CharacterOutfit.apply(model, look)
	# After the level has built its markers.
	_place.call_deferred()
	var anim := find_child("AnimationPlayer", true, false) as AnimationPlayer
	if anim != null and anim.has_animation(idle_clip):
		anim.get_animation(idle_clip).loop_mode = Animation.LOOP_LINEAR
		anim.play(idle_clip)


## Turns to look at `at` (someone who comes to talk, F9 task 6).
func face_towards(at: Vector3) -> void:
	var to: Vector3 = at - global_position
	if Vector2(to.x, to.z).length_squared() > 0.0001:
		# The model's front is +Z.
		global_rotation.y = atan2(to.x, to.z)


func _place() -> void:
	var m: Marker3D = level.marker_node(marker)
	global_position = m.global_position
	global_rotation.y = m.global_rotation.y
	if face != null:
		var to: Vector3 = face.global_position - global_position
		# The model's front is +Z.
		global_rotation.y = atan2(to.x, to.z)
