extends GdUnitTestSuite
## Unit: tools/capture_sector.gd frames its shots on markers that Carmenca really has.
## The capture itself needs a window and is not run here.

const TOOL: String = "res://tools/capture_sector.gd"
const LAYOUT: String = "res://resources/levels/carmenca_layout.tres"


func test_every_shot_uses_a_marker_of_the_layout() -> void:
	var constants: Dictionary = (load(TOOL) as GDScript).get_script_constant_map()
	var shots: Array = (constants["SHOTS"] as Array).duplicate()
	shots.append(constants["FIGHT_SHOT"])
	var layout := load(LAYOUT) as SectorLayout
	var markers: Array[StringName] = [&"Start", &"Huaca"]
	for i: int in layout.encounters.size():
		markers.append(StringName("Encounter%d" % (i + 1)))
	for shot: Array in shots:
		assert_array(markers).contains([shot[1]])


func test_shot_names_are_unique_and_facings_are_not_zero() -> void:
	var constants: Dictionary = (load(TOOL) as GDScript).get_script_constant_map()
	var names: Array[String] = []
	for shot: Array in constants["SHOTS"]:
		assert_bool(names.has(shot[0])).is_false()
		names.append(shot[0])
		assert_bool((shot[2] as Vector3).is_zero_approx()).is_false()
