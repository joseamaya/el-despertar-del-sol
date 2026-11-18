extends GdUnitTestSuite
## Integration: the huaca in Carmenca (F4 task 4). The offering prompt shows only near
## the huaca; the offering raises stamina for good; the vision thickens the fog, raises
## the stone figures and puts everything back; then Cusi speaks and the slice goes on.

const SCENE: String = "res://scenes/levels/carmenca.tscn"
## The rite lasts ~7 s of game time: run it faster.
const TIME_SCALE: float = 4.0

var _runner: GdUnitSceneRunner
var _level: SectorLevel
var _slice: SliceDirector
var _point: InteractionPoint
var _prompt: InteractionPrompt
var _rite: HuacaRite
var _player: PlayerController


func before_test() -> void:
	_runner = scene_runner(SCENE)
	_level = _runner.find_child("SectorLevel") as SectorLevel
	_slice = _runner.find_child("SliceDirector") as SliceDirector
	_point = _runner.find_child("InteractionPoint") as InteractionPoint
	_prompt = _runner.find_child("InteractionPrompt") as InteractionPrompt
	_rite = _runner.find_child("HuacaRite") as HuacaRite
	_player = _runner.find_child("Player") as PlayerController
	(_runner.find_child("CameraRig") as CameraController).capture_mouse = false
	await _frames(5)
	await _to_offering()


func after_test() -> void:
	Engine.time_scale = 1.0


func _frames(count: int) -> void:
	for i: int in count:
		await get_tree().physics_frame


## Plays the slice up to the offering: opening talk, first skirmish.
func _to_offering() -> void:
	var talk := _runner.find_child("DialoguePlayer") as DialoguePlayer
	while talk.is_playing():
		talk.advance()
	await _frames(2)
	var arena := _runner.find_child("ArenaController") as ArenaController
	for enemy: EnemyController in arena.alive_enemies():
		enemy.health.apply_damage(enemy.health.get_maximum())
	await _frames(3)


func _stand(offset: Vector2) -> void:
	var at: Vector3 = _level.to_global_point(_level.layout.huaca + offset)
	_player.respawn(at + Vector3.UP * 0.1, 0.0)
	await _frames(3)


func test_prompt_shows_only_near_the_huaca() -> void:
	assert_int(_slice.flow.current().kind).is_equal(SliceStep.Kind.INTERACT)
	await _stand(Vector2(0.0, 15.0))
	assert_bool(_prompt.is_showing()).is_false()
	assert_bool(_point.try_interact()).is_false()
	await _stand(Vector2(0.0, 3.2))
	assert_bool(_prompt.is_showing()).is_true()
	assert_str(_prompt.shown_text()).is_equal(tr(&"PROMPT_OFFERING"))


func test_offering_and_vision_then_cusi_speaks() -> void:
	var stamina := _player.get_node(^"Stamina") as StaminaComponent
	var env: Environment = _level.environment
	var rest_density: float = env.fog_density
	var rest_far: float = _player.camera.far
	var offered: Array[StringName] = []
	_rite.offering_made.connect(func(m: StringName) -> void: offered.append(m))
	await _stand(Vector2(0.0, 3.2))
	assert_bool(_point.try_interact()).is_true()
	await _frames(2)
	assert_bool(_prompt.is_showing()).is_false()
	assert_array(offered).is_equal([&"Huaca"])
	assert_float(stamina.get_maximum()).is_equal(110.0)
	assert_bool(_rite.is_playing()).is_true()
	Engine.time_scale = TIME_SCALE
	# Peak of the vision: thick fog, short view, figures standing.
	var t: HuacaRiteTuning = _rite.tuning
	await get_tree().create_timer(t.offering_time + t.fade_in + t.hold * 0.5).timeout
	assert_float(env.fog_density).is_greater(rest_density * 5.0)
	assert_float(_player.camera.far).is_less(rest_far)
	var figures: Node = _level.sector.get_node_or_null(^"VisionFigures")
	assert_object(figures).is_not_null()
	assert_int(figures.get_child_count()).is_equal(t.figures)
	assert_bool(_player.get_node(^"Combat").is_physics_processing()).is_false()
	# After: everything as before, and Cusi speaks.
	while _rite.is_playing():
		await _frames(5)
	await _frames(5)
	Engine.time_scale = 1.0
	assert_float(env.fog_density).is_equal_approx(rest_density, 0.0001)
	assert_float(_player.camera.far).is_equal_approx(rest_far, 0.01)
	assert_object(_level.sector.get_node_or_null(^"VisionFigures")).is_null()
	assert_int(_slice.flow.current().kind).is_equal(SliceStep.Kind.DIALOGUE)
	var box := _runner.find_child("DialogueBox") as DialogueBox
	assert_str(box.shown_text()).is_equal(tr(&"DLG_HUACA_1"))
