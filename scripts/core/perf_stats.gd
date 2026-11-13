class_name PerfStats
extends RefCounted
## Pure frame-time statistics for performance benchmarks.
## Frame times are in seconds; results are reported in FPS and milliseconds.


## Average FPS over the whole capture (total frames / total time).
static func average_fps(frame_times: PackedFloat64Array) -> float:
	var total: float = _sum(frame_times)
	return 0.0 if total <= 0.0 else frame_times.size() / total


## "1 % low": FPS computed from the slowest 1 % of frames (at least one frame).
static func low_1_percent_fps(frame_times: PackedFloat64Array) -> float:
	if frame_times.is_empty():
		return 0.0
	var sorted: PackedFloat64Array = frame_times.duplicate()
	sorted.sort()
	var count: int = maxi(1, int(ceil(sorted.size() * 0.01)))
	var worst: PackedFloat64Array = sorted.slice(sorted.size() - count)
	return 1.0 / (_sum(worst) / count)


## Frame time (ms) at the given percentile (0..100), nearest-rank method.
static func percentile_ms(frame_times: PackedFloat64Array, percentile: float) -> float:
	if frame_times.is_empty():
		return 0.0
	var sorted: PackedFloat64Array = frame_times.duplicate()
	sorted.sort()
	var rank: int = clampi(int(ceil(percentile / 100.0 * sorted.size())) - 1, 0, sorted.size() - 1)
	return sorted[rank] * 1000.0


## Fraction (0..1) of frames slower than `budget_seconds` (1/60 for 60 FPS).
static func fraction_over_budget(frame_times: PackedFloat64Array, budget_seconds: float) -> float:
	if frame_times.is_empty():
		return 0.0
	var over: int = 0
	for t: float in frame_times:
		if t > budget_seconds:
			over += 1
	return float(over) / frame_times.size()


static func _sum(values: PackedFloat64Array) -> float:
	var total: float = 0.0
	for v: float in values:
		total += v
	return total
