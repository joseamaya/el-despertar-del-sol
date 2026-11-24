extends GdUnitTestSuite
## The hub's doors (F8 task 8): only the open missions have a door that works; near one,
## the prompt names it, and choosing it asks to play it.

const SCENE: String = "res://scenes/levels/centro.tscn"
const CHAPTER: String = "res://resources/chapters/capitulo_1.tres"

var _runner: GdUnitSceneRunner
var _doors: HubDoors


func before_test() -> void:
	_runner = scene_runner(SCENE)
	(_runner.find_child("CameraRig") as CameraController).capture_mouse = false
	_doors = _runner.find_child("HubDoors") as HubDoors
	var progress := ChapterProgress.new(load(CHAPTER) as ChapterData)
	progress.complete(&"prologo")
	progress.complete(&"carmenca")
	_doors.progress = progress
	await _runner.simulate_frames(5)


func test_open_missions_have_doors() -> void:
	assert_array(_doors.open_doors()).contains_exactly([&"llamas", &"prisioneros", &"disputa"])


func test_near_a_door_the_prompt_names_it() -> void:
	var level := _runner.find_child("SectorLevel") as SectorLevel
	var player := _runner.find_child("Player") as PlayerController
	player.global_position = level.marker_position(&"Door_llamas") + Vector3.UP * 0.1
	await _runner.simulate_frames(3)
	assert_str(String(_doors.nearest_open_door())).is_equal("llamas")
	var prompt := _runner.find_child("InteractionPrompt") as InteractionPrompt
	var label := prompt.find_child("*", true, false) as Label
	var shown: Array[String] = []
	for l: Label in prompt.find_children("*", "Label", true, false):
		if l.visible:
			shown.append(l.text)
	assert_str(" ".join(shown)).contains(tr(&"MISSION_LLAMAS"))
	assert_object(label).is_not_null()


func test_only_open_missions_can_be_chosen() -> void:
	var chosen: Array[StringName] = []
	_doors.mission_chosen.connect(func(id: StringName) -> void: chosen.append(id))
	assert_bool(_doors.choose(&"combate_visible")).is_false()
	assert_bool(_doors.choose(&"llamas")).is_true()
	assert_array(chosen).contains_exactly([&"llamas"])


## F8 task 11: the hub has no huaca, no llamas and no comunero on the path.
func test_no_huaca_llamas_or_comunero_in_the_hub() -> void:
	var level := _runner.find_child("SectorLevel") as SectorLevel
	assert_object(level.sector.get_node_or_null(^"HuacaMesh")).is_null()
	assert_array((_runner.find_child("LlamaPen") as LlamaPen).llamas()).is_empty()
	assert_bool((_runner.find_child("Comunero") as Node3D).visible).is_false()
