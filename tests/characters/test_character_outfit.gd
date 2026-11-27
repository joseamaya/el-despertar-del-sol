extends GdUnitTestSuite
## CharacterOutfit (F4 task 10): dresses the UAL mannequin with a look (both surfaces
## tinted, pieces hung from their bones), dressing again replaces the outfit, and the
## game's looks only use bones the mannequin has. In Carmenca, Cusi, Vicaquirao, the
## comunero and the comuneros at the pass wear their looks. Since F10 task 1 the pieces are
## one mesh skinned to their bones: one draw call per character, following the pose.

const MODEL: String = "res://assets/characters/stock/ual1_standard.glb"
const LOOKS: String = "res://resources/characters"
const SCENE: String = "res://scenes/levels/carmenca.tscn"


func _model() -> Node3D:
	var model := auto_free((load(MODEL) as PackedScene).instantiate()) as Node3D
	add_child(model)
	return model


func _skeleton(model: Node3D) -> Skeleton3D:
	return model.find_child("GeneralSkeleton", true, false) as Skeleton3D


func _outfits(model: Node3D) -> Array[MeshInstance3D]:
	var out: Array[MeshInstance3D] = []
	for child: Node in _skeleton(model).get_children():
		if child.name.begins_with(CharacterOutfit.PREFIX) and not child.is_queued_for_deletion():
			out.append(child as MeshInstance3D)
	return out


## The bones the outfit is bound to.
func _bound_bones(model: Node3D) -> Array[StringName]:
	var out: Array[StringName] = []
	var skin: Skin = _outfits(model)[0].skin
	for i: int in skin.get_bind_count():
		out.append(skin.get_bind_name(i))
	out.sort()
	return out


## The bones a look hangs pieces from, once each.
func _look_bones(look: CharacterLook) -> Array[StringName]:
	var out: Array[StringName] = []
	for part: LookPart in look.parts:
		if not out.has(part.bone):
			out.append(part.bone)
	out.sort()
	return out


## Vertices the look's pieces have, one by one.
func _look_vertices(look: CharacterLook) -> int:
	var total: int = 0
	for part: LookPart in look.parts:
		var arrays: Array = (CharacterOutfit.mesh_for(part) as PrimitiveMesh).get_mesh_arrays()
		total += (arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array).size()
	return total


func _vertices(outfit: MeshInstance3D) -> int:
	return (outfit.mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX] as PackedVector3Array).size()


func test_dresses_surfaces_and_bones() -> void:
	var model: Node3D = _model()
	var look := load(LOOKS.path_join("cusi_yupanqui.tres")) as CharacterLook
	CharacterOutfit.apply(model, look)
	var body := _skeleton(model).find_child("Mannequin", false, false) as MeshInstance3D
	var skin := body.get_surface_override_material(0) as StandardMaterial3D
	assert_object(skin).is_not_null()
	assert_that(skin.albedo_color).is_equal(look.skin)
	var joints := body.get_surface_override_material(1) as StandardMaterial3D
	assert_that(joints.albedo_color).is_equal(look.joints)
	var outfits: Array[MeshInstance3D] = _outfits(model)
	assert_int(outfits.size()).is_equal(1)
	assert_int(outfits[0].mesh.get_surface_count()).is_equal(1)
	assert_object(outfits[0].get_node(outfits[0].skeleton)).is_same(_skeleton(model))
	assert_array(_bound_bones(model)).is_equal(_look_bones(look))
	assert_int(_vertices(outfits[0])).is_equal(_look_vertices(look))


## A piece sits where it hung from its bone before F10: the bone's pose times its offset.
func test_pieces_follow_their_bones() -> void:
	var model: Node3D = _model()
	var look := load(LOOKS.path_join("cusi_yupanqui.tres")) as CharacterLook
	CharacterOutfit.apply(model, look)
	var skeleton: Skeleton3D = _skeleton(model)
	var first: LookPart = look.parts[0]
	var expected: Vector3 = (
		skeleton.get_bone_global_rest(skeleton.find_bone(first.bone)) * first.offset
	)
	var arrays: Array = (CharacterOutfit.mesh_for(first) as PrimitiveMesh).get_mesh_arrays()
	var count: int = (arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array).size()
	var verts: PackedVector3Array = _outfits(model)[0].mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]
	var centre := Vector3.ZERO
	for i: int in count:
		centre += verts[i]
	assert_vector(centre / count).is_equal_approx(expected, Vector3.ONE * 0.02)
	var bones: PackedInt32Array = _outfits(model)[0].mesh.surface_get_arrays(0)[Mesh.ARRAY_BONES]
	assert_str(String(_outfits(model)[0].skin.get_bind_name(bones[0]))).is_equal(String(first.bone))


func test_dressing_again_replaces_the_outfit() -> void:
	var model: Node3D = _model()
	CharacterOutfit.apply(model, load(LOOKS.path_join("cusi_yupanqui.tres")) as CharacterLook)
	var comunero := load(LOOKS.path_join("comunero.tres")) as CharacterLook
	CharacterOutfit.apply(model, comunero)
	assert_int(_outfits(model).size()).is_equal(1)
	assert_int(_vertices(_outfits(model)[0])).is_equal(_look_vertices(comunero))


func test_every_look_uses_real_bones_and_shapes() -> void:
	var skeleton: Skeleton3D = _skeleton(_model())
	for name: String in DirAccess.get_files_at(LOOKS):
		if not name.ends_with(".tres"):
			continue
		var look := load(LOOKS.path_join(name)) as CharacterLook
		assert_array(look.parts).override_failure_message(name).is_not_empty()
		for part: LookPart in look.parts:
			(
				assert_int(skeleton.find_bone(part.bone))
				. override_failure_message("%s: %s" % [name, part.bone])
				. is_greater_equal(0)
			)
			assert_object(CharacterOutfit.mesh_for(part)).is_not_null()


func test_carmenca_characters_wear_their_looks() -> void:
	var runner: GdUnitSceneRunner = scene_runner(SCENE)
	await runner.simulate_frames(5)
	var expected: Dictionary[String, String] = {
		"Player/Visual/Model": "cusi_yupanqui.tres",
		"Vicaquirao/Model": "vicaquirao.tres",
		"Comunero/Model": "comunero.tres",
	}
	var root: Node = runner.scene()
	for path: String in expected:
		var model := root.get_node(path) as Node3D
		var look := load(LOOKS.path_join(expected[path])) as CharacterLook
		assert_int(_vertices(_outfits(model)[0])).override_failure_message(path).is_equal(
			_look_vertices(look)
		)
	var allies := runner.find_child("SupportAllies") as SupportAllies
	assert_object(allies.tuning.look).is_same(load(LOOKS.path_join("comunero.tres")))


## F10 task 1: the mannequin is imported with levels of detail, so far characters cost a
## small part of their 13,7 k triangles (the hub went from 1,12 M to 0,92 M primitives).
func test_the_mannequin_is_imported_with_lods() -> void:
	var settings: String = FileAccess.get_file_as_string(MODEL + ".import")
	assert_str(settings).contains("meshes/generate_lods=true")
