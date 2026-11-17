extends GdUnitTestSuite
## Unit: SectorGround options (F3 task 10): coarse sides with no cracks at the seam, and
## a ground that can skip sun shadows.

const LAYOUT: String = "res://resources/levels/carmenca_layout.tres"
const PALETTE: String = "res://resources/style/palette_amanecer_calido.tres"


func _build(side_cell: float, shadow: bool) -> Node3D:
	var layout := (load(LAYOUT) as SectorLayout).duplicate() as SectorLayout
	layout.side_cell = side_cell
	layout.ground_shadow = shadow
	var root := auto_free(Node3D.new()) as Node3D
	SectorGround.build(
		root, layout, load(PALETTE) as PaletteTuning, SectorBuilder.HeightGrid.new(layout)
	)
	return root


func _vertices(root: Node3D) -> Array[PackedVector3Array]:
	var out: Array[PackedVector3Array] = []
	for node: Node in root.get_children():
		var mi := node as MeshInstance3D
		if mi == null:
			continue
		var verts: PackedVector3Array = mi.mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]
		var moved := PackedVector3Array()
		for v: Vector3 in verts:
			moved.append(v + mi.position)
		out.append(moved)
	return out


func test_coarse_sides_cut_triangles_without_cracks() -> void:
	var fine: int = 0
	for v: PackedVector3Array in _vertices(_build(2.0, true)):
		fine += v.size()
	var parts: Array[PackedVector3Array] = _vertices(_build(8.0, true))
	assert_int(parts.size()).is_equal(3)
	var coarse: int = 0
	for v: PackedVector3Array in parts:
		coarse += v.size()
	assert_int(coarse).is_less(int(fine * 0.75))
	# Every vertex of a side mesh on the seam has a centre vertex at the same point.
	var centre: Dictionary = {}
	for v: Vector3 in parts[0]:
		centre[Vector3(snappedf(v.x, 0.01), snappedf(v.y, 0.01), snappedf(v.z, 0.01))] = true
	var strip: float = 0.0
	for v: Vector3 in parts[0]:
		strip = maxf(strip, v.x)
	var checked: int = 0
	for v: Vector3 in parts[2]:
		if absf(v.x - strip) < 0.01:
			var key := Vector3(snappedf(v.x, 0.01), snappedf(v.y, 0.01), snappedf(v.z, 0.01))
			assert_bool(centre.has(key)).override_failure_message("Crack at %s" % v).is_true()
			checked += 1
	assert_int(checked).is_greater(300)


func test_ground_shadow_option() -> void:
	for node: Node in _build(8.0, false).get_children():
		if node is MeshInstance3D:
			assert_int((node as MeshInstance3D).cast_shadow).is_equal(
				GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			)
	for node: Node in _build(2.0, true).get_children():
		if node is MeshInstance3D:
			assert_int((node as MeshInstance3D).cast_shadow).is_equal(
				GeometryInstance3D.SHADOW_CASTING_SETTING_ON
			)
