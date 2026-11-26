extends GdUnitTestSuite
## The people of the hub (F9 task 5): Apo Mayta and the three curacas stand at their
## markers, dressed. They differ by what they wear and on their heads, not only by colour
## (GDD §10.5), and only the Inca nobles wear ear spools.

const SCENE: String = "res://scenes/levels/centro.tscn"
const CURACAS: Array[String] = ["curaca_llamas", "curaca_prisioneros", "curaca_disputa"]
const NODES: Dictionary[StringName, StringName] = {
	&"ApoMayta": &"ApoMayta",
	&"CuracaLlamas": &"Curaca_llamas",
	&"CuracaPrisioneros": &"Curaca_prisioneros",
	&"CuracaDisputa": &"Curaca_disputa",
	&"Vicaquirao": &"Mentor",
}


func _look(file: String) -> CharacterLook:
	return load("res://resources/characters/%s.tres" % file) as CharacterLook


## Names of the pieces a look wears on `bone`, plus every piece other than the unku.
func _outline(look: CharacterLook) -> PackedStringArray:
	var out := PackedStringArray()
	for part: LookPart in look.parts:
		out.append("%s:%s:%d:%s" % [part.bone, part.name, part.shape, part.size])
	out.sort()
	return out


func _head(look: CharacterLook) -> PackedStringArray:
	var out := PackedStringArray()
	for part: LookPart in look.parts:
		if part.bone == &"Head" and not part.name.begins_with("Ear"):
			out.append("%s:%d:%s" % [part.name, part.shape, part.size])
	out.sort()
	return out


func test_each_one_has_a_headdress_of_their_own() -> void:
	var seen: Array[PackedStringArray] = []
	for file: String in ["apo_mayta"] + CURACAS:
		var head: PackedStringArray = _head(_look(file))
		assert_int(head.size()).override_failure_message(file).is_greater(0)
		(
			assert_bool(seen.has(head))
			. override_failure_message(file + " repeats a headdress")
			. is_false()
		)
		seen.append(head)


func test_they_differ_by_more_than_colour() -> void:
	var files: Array[String] = ["apo_mayta", "vicaquirao", "cusi_yupanqui"]
	files.append_array(CURACAS)
	for i: int in files.size():
		for j: int in range(i + 1, files.size()):
			(
				assert_bool(_outline(_look(files[i])) == _outline(_look(files[j])))
				. override_failure_message("%s and %s only change colour" % [files[i], files[j]])
				. is_false()
			)


func test_only_the_inca_nobles_wear_ear_spools() -> void:
	for file: String in ["apo_mayta", "cusi_yupanqui"]:
		assert_bool(_has_ears(_look(file))).override_failure_message(file).is_true()
	for file: String in CURACAS:
		assert_bool(_has_ears(_look(file))).override_failure_message(file).is_false()


func _has_ears(look: CharacterLook) -> bool:
	for part: LookPart in look.parts:
		if part.name.begins_with("Ear"):
			return true
	return false


func test_they_stand_at_their_markers_dressed() -> void:
	var runner: GdUnitSceneRunner = scene_runner(SCENE)
	var level := runner.find_child("SectorLevel") as SectorLevel
	for i: int in 5:
		await get_tree().process_frame
	for node: StringName in NODES:
		# By path: the level also has markers with these names.
		var npc := runner.scene().get_node_or_null(NodePath(String(node))) as SectorNpc
		assert_object(npc).override_failure_message(String(node)).is_not_null()
		var at: Vector3 = level.marker_node(NODES[node]).global_position
		(
			assert_float(npc.global_position.distance_to(at))
			. override_failure_message(String(node))
			. is_less(0.1)
		)
		assert_bool(npc.visible).is_true()
		var model := npc.find_child("Model", false, false) as Node3D
		var outfit: Array[Node] = model.find_children("Outfit_*", "BoneAttachment3D", true, false)
		assert_int(outfit.size()).override_failure_message(String(node)).is_greater(0)
