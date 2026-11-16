extends GdUnitTestSuite
## Unit: tools/scene_audit.gd measures draw cost, physics and coupling smells.

const AUDIT: String = "res://tools/scene_audit.gd"
const SMELLY: String = "user://smelly_script_for_audit.gd"


func _audit(scene: Node) -> Dictionary:
	var tool: GDScript = load(AUDIT)
	return tool.call(&"audit", scene)


func test_counts_meshes_triangles_and_shadow_passes() -> void:
	var scene := auto_free(Node3D.new()) as Node3D
	var box := MeshInstance3D.new()
	box.mesh = BoxMesh.new()
	scene.add_child(box)
	var plain := MeshInstance3D.new()
	plain.mesh = LowPolyMesh.box(Vector3.ONE, Color.WHITE)
	plain.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	scene.add_child(plain)
	var r: Dictionary = _audit(scene)
	var draw: Dictionary = r["draw"]
	assert_int(draw["surfaces"]).is_equal(2)
	assert_int(draw["with_shadow"]).is_equal(1)
	assert_int(r["draw_calls_estimate"]).is_equal(3)
	# BoxMesh is indexed (12 triangles); the generated box is not (12 triangles).
	assert_int(draw["primitives"]).is_equal(24)


func test_reports_shapes_and_broken_nodes() -> void:
	var scene := auto_free(Node3D.new()) as Node3D
	var body := StaticBody3D.new()
	var good := CollisionShape3D.new()
	good.shape = BoxShape3D.new()
	body.add_child(good)
	body.add_child(CollisionShape3D.new())
	scene.add_child(body)
	scene.add_child(Node3D.new())
	var r: Dictionary = _audit(scene)
	assert_int((r["physics"] as Dictionary)["shapes"]).is_equal(1)
	assert_int((r["empty_or_broken"] as Array).size()).is_equal(2)


func test_finds_coupling_smells_in_scripts() -> void:
	var file := FileAccess.open(SMELLY, FileAccess.WRITE)
	file.store_string("extends Node\nfunc _ready() -> void:\n\tget_parent().get_parent()\n")
	file.close()
	var tool: GDScript = load(AUDIT)
	var report: Dictionary = tool.call(&"_scan_script", SMELLY)
	assert_int((report["smells"] as Array).size()).is_equal(1)
	assert_bool(report["too_long"]).is_false()
	DirAccess.remove_absolute(ProjectSettings.globalize_path(SMELLY))
