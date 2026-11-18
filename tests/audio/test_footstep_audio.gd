extends GdUnitTestSuite
## Footsteps (F4 task 9): the surface underfoot comes from the layout (path, the stone
## stairs of the terraces, grass), and walking in Carmenca takes steps.

const SCENE: String = "res://scenes/levels/carmenca.tscn"
const LAYOUT: String = "res://resources/levels/carmenca_layout.tres"


func test_surface_follows_the_layout() -> void:
	var layout := load(LAYOUT) as SectorLayout
	var steps: PackedVector3Array = layout.terrace_steps()
	assert_array(Array(steps)).is_not_empty()
	var z_stairs: float = steps[0].x - 0.5
	var on_stairs := Vector2(layout.path_x_at(z_stairs), z_stairs)
	assert_int(FootstepAudio.surface_at(layout, on_stairs, 0.3)).is_equal(
		FootstepAudio.Surface.STONE
	)
	var z_path: float = 0.0
	(
		assert_int(FootstepAudio.surface_at(layout, Vector2(layout.path_x_at(z_path), z_path), 0.3))
		. is_equal(FootstepAudio.Surface.PATH)
	)
	(
		assert_int(
			FootstepAudio.surface_at(layout, Vector2(layout.path_x_at(z_path) + 12.0, z_path), 0.3)
		)
		. is_equal(FootstepAudio.Surface.GRASS)
	)


func test_walking_takes_steps() -> void:
	var runner: GdUnitSceneRunner = scene_runner(SCENE)
	(runner.find_child("CameraRig") as CameraController).capture_mouse = false
	await runner.simulate_frames(10)
	var talk := runner.find_child("DialoguePlayer") as DialoguePlayer
	while talk.is_playing():
		talk.advance()
	var steps := runner.find_child("FootstepAudio") as FootstepAudio
	# On the straight path below the houses, walking uphill (-Z in the layout).
	var level := runner.find_child("SectorLevel") as SectorLevel
	var player := runner.find_child("Player") as PlayerController
	var rig := runner.find_child("CameraRig") as CameraController
	var from: Vector3 = level.to_global_point(Vector2(0.0, 40.0))
	var to: Vector3 = level.to_global_point(Vector2(0.0, 15.0))
	player.respawn(from + Vector3.UP * 0.1, 0.0)
	rig.yaw = atan2(-(to - from).x, -(to - from).z)
	await runner.simulate_frames(5)
	Input.action_press(&"move_forward")
	for i: int in 180:
		await get_tree().physics_frame
	Input.action_release(&"move_forward")
	assert_int(steps.steps_taken()).is_greater(2)
	assert_int(steps.last_surface()).is_equal(FootstepAudio.Surface.PATH)
