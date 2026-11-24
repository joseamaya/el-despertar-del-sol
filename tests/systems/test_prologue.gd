extends GdUnitTestSuite
## The prologue (F8 tasks 8 and 11): its captions are the opening shots, so E / A skips
## them, as in Carmenca, and the player goes straight to meeting Vicaquirao.

const SCENE: String = "res://scenes/levels/prologo.tscn"


func test_e_skips_the_captions() -> void:
	var runner := scene_runner(SCENE)
	(runner.find_child("CameraRig") as CameraController).capture_mouse = false
	await runner.simulate_frames(5)
	var slice := runner.find_child("SliceDirector") as SliceDirector
	assert_bool(slice.is_in_intro()).is_true()
	slice.skip_intro()
	assert_bool(slice.is_in_intro()).is_false()
	assert_int(slice.flow.current().kind).is_equal(SliceStep.Kind.REACH)
	assert_str(String(slice.flow.current().marker)).is_equal("Mentor")
