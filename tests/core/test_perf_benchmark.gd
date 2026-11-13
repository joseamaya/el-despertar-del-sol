extends GdUnitTestSuite
## Smoke test: the proxy scene loads and the benchmark stays inert without --benchmark.

const SCENE: String = "res://scenes/tests/perf_carmenca_proxy.tscn"


func test_proxy_scene_loads_with_expected_load() -> void:
	var runner := scene_runner(SCENE)
	var bench := runner.find_child("PerfBenchmark") as PerfBenchmark
	assert_object(bench).is_not_null()
	assert_object(bench.camera).is_not_null()
	var rocks := runner.find_child("Rocks") as MultiMeshInstance3D
	var ichu := runner.find_child("Ichu") as MultiMeshInstance3D
	assert_int(rocks.multimesh.instance_count).is_equal(2000)
	assert_int(ichu.multimesh.instance_count).is_equal(1500)


func test_benchmark_is_inert_without_flag() -> void:
	var runner := scene_runner(SCENE)
	await runner.simulate_frames(10)
	var bench := runner.find_child("PerfBenchmark") as PerfBenchmark
	assert_bool(bench.is_running()).is_false()
	assert_int(DisplayServer.window_get_vsync_mode()).is_not_equal(DisplayServer.VSYNC_DISABLED)


func test_report_has_expected_keys() -> void:
	var runner := scene_runner(SCENE)
	var bench := runner.find_child("PerfBenchmark") as PerfBenchmark
	var report: Dictionary = bench.build_report()
	for key: String in ["renderer", "gpu", "render_size", "avg_fps", "low_1_fps", "p99_ms"]:
		assert_bool(report.has(key)).is_true()
