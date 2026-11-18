extends GdUnitTestSuite
## CharacterOutfit (F4 task 10): dresses the UAL mannequin with a look (both surfaces
## tinted, pieces hung from their bones), dressing again replaces the outfit, and the
## game's looks only use bones the mannequin has. In Carmenca, Cusi, Vicaquirao, the
## comunero and the comuneros at the pass wear their looks.

const MODEL: String = "res://assets/characters/stock/ual1_standard.glb"
const LOOKS: String = "res://resources/characters"
const SCENE: String = "res://scenes/levels/carmenca.tscn"


func _model() -> Node3D:
	var model := auto_free((load(MODEL) as PackedScene).instantiate()) as Node3D
	add_child(model)
	return model


func _skeleton(model: Node3D) -> Skeleton3D:
	return model.find_child("GeneralSkeleton", true, false) as Skeleton3D


func _pieces(model: Node3D) -> Array[Node]:
	var out: Array[Node] = []
	for socket: Node in _skeleton(model).get_children():
		if socket.name.begins_with(CharacterOutfit.PREFIX):
			out.append_array(socket.get_children())
	return out


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
	assert_int(_pieces(model).size()).is_equal(look.parts.size())
	for part: LookPart in look.parts:
		var socket := (
			_skeleton(model).get_node_or_null(NodePath(CharacterOutfit.PREFIX + String(part.bone)))
			as BoneAttachment3D
		)
		assert_object(socket).override_failure_message(part.name).is_not_null()
		assert_str(socket.bone_name).is_equal(part.bone)


func test_dressing_again_replaces_the_outfit() -> void:
	var model: Node3D = _model()
	CharacterOutfit.apply(model, load(LOOKS.path_join("cusi_yupanqui.tres")) as CharacterLook)
	var comunero := load(LOOKS.path_join("comunero.tres")) as CharacterLook
	CharacterOutfit.apply(model, comunero)
	await get_tree().process_frame
	assert_int(_pieces(model).size()).is_equal(comunero.parts.size())


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
		assert_int(_pieces(model).size()).override_failure_message(path).is_equal(look.parts.size())
	var allies := runner.find_child("SupportAllies") as SupportAllies
	assert_object(allies.tuning.look).is_same(load(LOOKS.path_join("comunero.tres")))
