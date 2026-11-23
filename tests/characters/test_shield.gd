extends GdUnitTestSuite
## The huallcanca (F6 task 4): a round shield built from simple shapes, with its motif on
## the face, sitting on the forearm where its look says; Cusi carries the round one.


func _look() -> ShieldLook:
	var look := ShieldLook.new()
	look.mount_position = Vector3(0.1, 0.2, 0.3)
	look.mount_rotation_deg = Vector3(0, 90, 0)
	return look


func test_a_round_shield_has_rim_face_and_motif_and_no_fringe() -> void:
	var shield := auto_free(Shield.new()) as Shield
	shield.look = _look()
	add_child(shield)
	assert_object(shield.get_node_or_null(^"Rim")).is_not_null()
	assert_object(shield.get_node_or_null(^"Face")).is_not_null()
	assert_object(shield.get_node_or_null(^"Motif0")).is_not_null()
	assert_object(shield.get_node_or_null(^"Fringe")).is_null()
	assert_object((shield.get_node(^"Face") as MeshInstance3D).mesh).is_instanceof(CylinderMesh)
	assert_vector(shield.position).is_equal_approx(Vector3(0.1, 0.2, 0.3), Vector3.ONE * 0.001)
	assert_float(shield.rotation_degrees.y).is_equal_approx(90.0, 0.01)


func test_rebuild_follows_the_look() -> void:
	var shield := auto_free(Shield.new()) as Shield
	shield.look = _look()
	add_child(shield)
	shield.look.shape = ShieldLook.Shape.RECT
	shield.look.fringe_length = 0.2
	shield.rebuild()
	await get_tree().process_frame
	assert_object((shield.get_node(^"Face") as MeshInstance3D).mesh).is_instanceof(BoxMesh)
	assert_object(shield.get_node_or_null(^"Fringe")).is_not_null()


func test_cusi_carries_the_round_huallcanca() -> void:
	var player := (
		auto_free((load("res://scenes/player/player.tscn") as PackedScene).instantiate()) as Node
	)
	var shield := player.find_child("Huallcanca", true, false) as Shield
	assert_object(shield).is_not_null()
	assert_int(shield.look.shape).is_equal(ShieldLook.Shape.ROUND)
	assert_str(String(shield.get_parent().get("bone_name"))).is_equal("LeftLowerArm")
