extends GdUnitTestSuite
## Integration: the backdrop of Carmenca (valley, town, apus, smoke) hides under the
## sector, meets its lower edge, keeps the town in the valley and stays cheap to draw.

const SCENE: String = "res://scenes/levels/carmenca.tscn"

var _runner: GdUnitSceneRunner
var _level: SectorLevel


func before_test() -> void:
	_runner = scene_runner(SCENE)
	_level = _runner.find_child("SectorLevel") as SectorLevel
	await _runner.simulate_frames(2)


func _backdrop() -> Node3D:
	return _level.sector.get_node("Backdrop") as Node3D


func test_valley_stays_below_the_sector_and_meets_its_lower_edge() -> void:
	var b: BackdropLayout = _level.backdrop
	var l: SectorLayout = _level.layout
	for x: float in range(-110, 111, 10):
		for z: float in range(-160, 160, 20):
			var under: float = BackdropBuilder.height_at(b, l, x, z)
			assert_float(under).is_less_equal(l.height_at(x, z) - 20.0)
		var edge: float = BackdropBuilder.height_at(b, l, x, b.slope_start_z)
		assert_float(edge).is_equal_approx(l.height_at(x, b.slope_start_z), 0.5)


func test_town_lies_in_the_valley() -> void:
	var b: BackdropLayout = _level.backdrop
	var towns: int = 0
	for node: Node in _backdrop().get_children():
		if String(node.name).begins_with("Town"):
			towns += 1
			var aabb: AABB = (node as MeshInstance3D).get_aabb()
			assert_float(aabb.position.z).is_greater(b.slope_end_z)
			assert_float(aabb.position.y).is_less(b.floor_height + 40.0)
	assert_int(towns).is_equal(b.neighbourhoods)


func test_far_scenery_casts_no_shadow_and_ignores_fog() -> void:
	for node: Node in _backdrop().find_children("*", "GeometryInstance3D", true, false):
		var geo := node as GeometryInstance3D
		assert_int(geo.cast_shadow).is_equal(GeometryInstance3D.SHADOW_CASTING_SETTING_OFF)
		if geo.material_override is StandardMaterial3D:
			assert_bool((geo.material_override as StandardMaterial3D).disable_fog).is_true()


func test_smoke_columns_and_apus_are_there() -> void:
	var b: BackdropLayout = _level.backdrop
	var smoke: int = 0
	var apus: int = 0
	for node: Node in _backdrop().get_children():
		if String(node.name).begins_with("Smoke"):
			smoke += 1
			assert_object((node as MeshInstance3D).material_override).is_instanceof(ShaderMaterial)
		elif String(node.name).begins_with("Apu"):
			apus += 1
	assert_int(smoke).is_equal(b.smoke.size())
	assert_int(apus).is_equal(b.apus.size())


func test_camera_sees_the_whole_backdrop_and_starts_looking_down() -> void:
	var player := _runner.find_child("Player") as PlayerController
	var rig := _runner.find_child("CameraRig") as CameraController
	assert_float(player.camera.far).is_equal(_level.backdrop.view_distance)
	assert_float(rig.pitch).is_equal_approx(SectorLevel.START_PITCH, 0.001)


func test_backdrop_adds_few_draw_calls() -> void:
	var nodes: int = _backdrop().find_children("*", "GeometryInstance3D", true, false).size()
	var b: BackdropLayout = _level.backdrop
	# Valley + one mesh per neighbourhood + apus + smoke columns.
	assert_int(nodes).is_equal(1 + b.neighbourhoods + b.apus.size() + b.smoke.size())
	assert_int(nodes).is_less(25)
