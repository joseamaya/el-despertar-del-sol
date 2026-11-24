extends GdUnitTestSuite
## UAL2 Standard (F8 task 10, `docs/capitulo-1.md` §7): the pack imports with the same bone map
## as UAL1, so its clips drive the same skeleton the player and the warriors use; and it
## brings the clips planned for later (shield guard, block, throw, carrying).

const UAL1: String = "res://assets/characters/stock/ual1_standard.glb"
const UAL2: String = "res://assets/characters/stock/ual2_standard.glb"
const PLANNED: Array[StringName] = [
	&"Idle_Shield", &"Sword_Block", &"Shield_OneShot", &"OverhandThrow", &"Walk_Carry"
]


func _player(path: String) -> AnimationPlayer:
	var scene: Node = auto_free((load(path) as PackedScene).instantiate())
	return scene.find_children("*", "AnimationPlayer", true, false)[0] as AnimationPlayer


func _skeleton(path: String) -> Skeleton3D:
	var scene: Node = auto_free((load(path) as PackedScene).instantiate())
	return scene.find_children("*", "Skeleton3D", true, false)[0] as Skeleton3D


func test_brings_the_planned_clips() -> void:
	var anims: AnimationPlayer = _player(UAL2)
	for clip: StringName in PLANNED:
		assert_bool(anims.has_animation(clip)).override_failure_message(String(clip)).is_true()


func test_same_retargeted_skeleton_as_ual1() -> void:
	var a: Skeleton3D = _skeleton(UAL1)
	var b: Skeleton3D = _skeleton(UAL2)
	assert_str(b.name).is_equal(a.name)
	assert_int(b.get_bone_count()).is_equal(a.get_bone_count())
	for i: int in a.get_bone_count():
		assert_int(b.find_bone(a.get_bone_name(i))).is_greater_equal(0)


func test_clips_drive_bones_that_ual1_has() -> void:
	var a: Skeleton3D = _skeleton(UAL1)
	var clip: Animation = _player(UAL2).get_animation(&"Sword_Block")
	for t: int in clip.get_track_count():
		var path: NodePath = clip.track_get_path(t)
		if path.get_subname_count() > 0:
			assert_int(a.find_bone(path.get_subname(0))).is_greater_equal(0)
