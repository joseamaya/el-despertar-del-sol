class_name GuardPose
extends SkeletonModifier3D
## Raises the guard (F6 task 4): while the player blocks, turns the arm bones listed in
## `tuning` on top of the animated pose, by as much as the animator's guard blend. Only
## the bones listed move, so the legs keep walking. Lives under the Skeleton3D.

@export var tuning: GuardPoseTuning
@export var animator: CharacterAnimator

var _bone_ids: PackedInt32Array = PackedInt32Array()
var _turns: Array[Quaternion] = []


func _ready() -> void:
	assert(tuning != null and animator != null, "GuardPose: tuning and animator.")
	assert(tuning.bones.size() == tuning.rotations_deg.size(), "GuardPose: one turn per bone.")
	rebuild()


## Reads the bones and turns from `tuning` again (after changing it).
func rebuild() -> void:
	var skeleton: Skeleton3D = get_skeleton()
	_bone_ids.clear()
	_turns.clear()
	if skeleton == null:
		return
	for i: int in tuning.bones.size():
		var id: int = skeleton.find_bone(tuning.bones[i])
		assert(id >= 0, "GuardPose: no bone %s." % tuning.bones[i])
		_bone_ids.append(id)
		var euler: Vector3 = tuning.rotations_deg[i] * (PI / 180.0)
		_turns.append(Quaternion.from_euler(euler))


func _process_modification_with_delta(_delta: float) -> void:
	influence = animator.get_guard()
	if influence <= 0.001:
		return
	var skeleton: Skeleton3D = get_skeleton()
	for i: int in _bone_ids.size():
		var id: int = _bone_ids[i]
		skeleton.set_bone_pose_rotation(id, skeleton.get_bone_pose_rotation(id) * _turns[i])
