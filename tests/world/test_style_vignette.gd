extends GdUnitTestSuite
## Integration: the style vignette builds from a palette and rebuilds on swap.

const SCENE: String = "res://scenes/tests/style_vignette.tscn"


func test_builds_scenery_cameras_and_light() -> void:
	var runner := scene_runner(SCENE)
	var vignette := runner.scene() as StyleVignette
	await runner.simulate_frames(2)
	assert_int(vignette.count_meshes()).is_greater(15)
	assert_object(vignette.get_camera(StyleVignette.Shot.WIDE)).is_not_null()
	vignette.use_shot(StyleVignette.Shot.DETAIL)
	assert_bool(vignette.get_camera(StyleVignette.Shot.DETAIL).current).is_true()
	assert_int(vignette.find_children("*", "DirectionalLight3D", true, false).size()).is_equal(1)


func test_swapping_the_palette_rebuilds_with_its_colours() -> void:
	var runner := scene_runner(SCENE)
	var vignette := runner.scene() as StyleVignette
	var cold := load("res://resources/style/palette_altura_fria.tres") as PaletteTuning
	vignette.palette = cold
	vignette.rebuild()
	await runner.simulate_frames(2)
	var env := vignette.find_children("*", "WorldEnvironment", true, false)[0] as WorldEnvironment
	assert_object(env.environment.fog_light_color).is_equal(cold.fog_color)
	assert_int(vignette.find_children("*", "WorldEnvironment", true, false).size()).is_equal(1)
