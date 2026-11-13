extends GdUnitTestSuite
## Unit tests for frame-time statistics.

const EPS: float = 0.0001


func _frames(values: Array[float]) -> PackedFloat64Array:
	return PackedFloat64Array(values)


func test_average_fps_is_frames_over_total_time() -> void:
	var frames := _frames([0.01, 0.01, 0.02, 0.02])
	assert_float(PerfStats.average_fps(frames)).is_equal_approx(4.0 / 0.06, EPS)


func test_low_1_percent_uses_slowest_frames() -> void:
	var values: Array[float] = []
	for i: int in 198:
		values.append(1.0 / 100.0)
	values.append(1.0 / 20.0)
	values.append(1.0 / 25.0)
	# 200 frames -> slowest 2 frames: 0.05 and 0.04 -> 1 / 0.045
	assert_float(PerfStats.low_1_percent_fps(_frames(values))).is_equal_approx(1.0 / 0.045, 0.01)


func test_low_1_percent_uses_at_least_one_frame() -> void:
	var frames := _frames([0.01, 0.02, 0.05])
	assert_float(PerfStats.low_1_percent_fps(frames)).is_equal_approx(20.0, EPS)


func test_percentile_nearest_rank() -> void:
	var values: Array[float] = []
	for i: int in 100:
		values.append((i + 1) / 1000.0)  # 1..100 ms
	assert_float(PerfStats.percentile_ms(_frames(values), 99.0)).is_equal_approx(99.0, EPS)
	assert_float(PerfStats.percentile_ms(_frames(values), 50.0)).is_equal_approx(50.0, EPS)


func test_fraction_over_budget() -> void:
	var frames := _frames([0.010, 0.016, 0.017, 0.030])
	assert_float(PerfStats.fraction_over_budget(frames, 1.0 / 60.0)).is_equal_approx(0.5, EPS)


func test_empty_capture_returns_zeros() -> void:
	var empty := PackedFloat64Array()
	assert_float(PerfStats.average_fps(empty)).is_equal(0.0)
	assert_float(PerfStats.low_1_percent_fps(empty)).is_equal(0.0)
	assert_float(PerfStats.percentile_ms(empty, 99.0)).is_equal(0.0)
	assert_float(PerfStats.fraction_over_budget(empty, 0.016)).is_equal(0.0)
