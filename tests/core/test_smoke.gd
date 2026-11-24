extends GdUnitTestSuite
## Smoke test: validates the toolchain (Godot + gdUnit4 + CI), not gameplay.

const MAIN_SCENE_PATH: String = "res://scenes/game.tscn"


func test_main_scene_is_configured() -> void:
	var configured: String = ProjectSettings.get_setting("application/run/main_scene")
	assert_str(configured).is_equal(MAIN_SCENE_PATH)


func test_main_scene_instantiates() -> void:
	var packed: PackedScene = load(MAIN_SCENE_PATH) as PackedScene
	assert_object(packed).is_not_null()
	var main: Node = auto_free(packed.instantiate())
	assert_object(main).is_instanceof(GameShell)


func test_engine_version_is_pinned() -> void:
	var info: Dictionary = Engine.get_version_info()
	assert_int(info["major"]).is_equal(4)
	assert_int(info["minor"]).is_equal(7)
