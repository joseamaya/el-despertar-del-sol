class_name SectorLayout
extends Resource
## The layout of a hillside sector as data (F3 task 4): a height profile along the slope,
## a walkable corridor with steep sides, the path and points of interest. Local frame:
## -Z is uphill. The level rotates the whole sector to face the real slope (Carmenca
## rises to the north-west of Cusco, HISTORICAL_REFERENCES).
##
## Terraces are steps in the profile: two points 1 m apart in Z with a jump in height.
## Retaining walls go wherever the profile climbs faster than WALL_GRADE.

## Grade (rise / run) above which a profile segment is a terrace step, not a slope.
const WALL_GRADE: float = 1.0
## A terrace step is short (1 m in the layouts). Longer steep segments are cliffs: no wall.
const STEP_MAX_RUN: float = 1.5

## Size of the sector (x across, y along the slope), metres.
@export var size: Vector2 = Vector2(240, 340)
## Height of the ground along the slope: points (z, height), any order (sorted on use).
@export var profile: PackedVector2Array = PackedVector2Array()
## Half width of the walkable corridor along the slope: points (z, half_width).
@export var corridor: PackedVector2Array = PackedVector2Array()
## Grade of the sides outside the corridor. Above 1.0 (45°) the player cannot climb them.
@export_range(0.5, 4.0, 0.05) var side_grade: float = 1.4
## Main path: points (x, z) from the start to the end of the sector.
@export var path: PackedVector2Array = PackedVector2Array()
@export_range(1.0, 6.0, 0.1, "suffix:m") var path_width: float = 2.6
## Retaining walls: thickness (covers the 1 m step cell) and how far into the sides.
@export_range(0.4, 1.5, 0.05, "suffix:m") var wall_thickness: float = 1.0
## Boundary walls where the ground falls away: (x0, z0, x1, z1) each.
@export var boundary_walls: PackedVector4Array = PackedVector4Array()
@export_range(0.5, 2.0, 0.05, "suffix:m") var boundary_height: float = 1.1
## Points of interest, all (x, z).
@export var start: Vector2 = Vector2.ZERO
@export var huaca: Vector2 = Vector2.ZERO
## Encounter zones: (x, z, radius). Order: skirmish 1, skirmish 2, the pass.
@export var encounters: PackedVector3Array = PackedVector3Array()
## Enemies waiting in each encounter zone (same order as `encounters`).
@export var encounter_enemies: PackedInt32Array = PackedInt32Array()
## Houses: (x, z, yaw in degrees).
@export var houses: PackedVector3Array = PackedVector3Array()
## Corrals: (x, z, radius); opening downhill (+Z).
@export var corrals: PackedVector3Array = PackedVector3Array()
## Crags framing the pass: (x, z, height).
@export var crags: PackedVector3Array = PackedVector3Array()
## Irrigation channel: points (x, z) along a terrace.
@export var channel: PackedVector2Array = PackedVector2Array()
## Loose rocks scattered over the sector (deterministic).
@export_range(0, 2000, 1) var rock_count: int = 160
@export var rock_seed: int = 3
## Performance (F3 task 10): whether the ground casts sun shadows (walls, houses and rocks
## always do), and the ground cell across X on the inaccessible sides (2 = same as the
## corridor).
@export var ground_shadow: bool = true
@export_range(2.0, 16.0, 1.0, "suffix:m") var side_cell: float = 2.0
## Vegetation (F3 task 8): plants per square metre on the steep sides and inside the
## corridor, how far up the sides they grow, and how far away they stop being drawn.
@export_range(0.0, 2.0, 0.005) var ichu_side_density: float = 0.6
@export_range(0.0, 2.0, 0.005) var ichu_corridor_density: float = 0.14
@export_range(0.0, 0.5, 0.001) var shrub_density: float = 0.012
@export_range(0.0, 80.0, 1.0, "suffix:m") var plant_side_band: float = 25.0
@export_range(10.0, 300.0, 1.0, "suffix:m") var plant_range: float = 65.0
@export_range(10.0, 100.0, 1.0, "suffix:m") var plant_chunk: float = 40.0
@export var plant_seed: int = 21
## Rotation of the whole sector around Y (degrees) so that local -Z faces the real uphill.
@export_range(-180.0, 180.0, 1.0, "suffix:°") var facing_deg: float = 45.0

# Sorted copies of profile and corridor, rebuilt when the source arrays change.
var _profile_src: PackedVector2Array
var _profile_sorted: PackedVector2Array
var _corridor_src: PackedVector2Array
var _corridor_sorted: PackedVector2Array


## Ground height at a local point: profile along Z plus the steep sides.
func height_at(x: float, z: float) -> float:
	var h: float = profile_at(z)
	var half: float = corridor_half_width(z)
	var outside: float = absf(x) - half
	if outside > 0.0:
		h += outside * side_grade
	return h


## Height of the profile alone (corridor centre).
func profile_at(z: float) -> float:
	if _profile_src != profile:
		_profile_src = profile.duplicate()
		_profile_sorted = _sorted(profile)
	return _interpolate(_profile_sorted, z)


func corridor_half_width(z: float) -> float:
	if _corridor_src != corridor:
		_corridor_src = corridor.duplicate()
		_corridor_sorted = _sorted(corridor)
	return _interpolate(_corridor_sorted, z)


## Terrace steps found in the profile: Vector3(z_low, height_low, height_high) for each
## segment steeper than WALL_GRADE and no longer than STEP_MAX_RUN, where z_low is the
## downhill edge of the step.
func terrace_steps() -> PackedVector3Array:
	var steps := PackedVector3Array()
	var pts: PackedVector2Array = _sorted(profile)
	for i: int in range(pts.size() - 1):
		var a: Vector2 = pts[i]
		var b: Vector2 = pts[i + 1]
		var run: float = absf(b.x - a.x)
		var rise: float = b.y - a.y
		if run > 0.0 and run <= STEP_MAX_RUN and absf(rise) / run > WALL_GRADE:
			var low: Vector2 = a if a.y < b.y else b
			var high: Vector2 = b if a.y < b.y else a
			steps.append(Vector3(low.x, low.y, high.y))
	return steps


## Path points in 3D on the ground (local frame).
func path_points() -> PackedVector3Array:
	var pts := PackedVector3Array()
	for p: Vector2 in path:
		pts.append(Vector3(p.x, height_at(p.x, p.y), p.y))
	return pts


## X where the path crosses `z`, or NAN if it does not.
func path_x_at(z: float) -> float:
	for i: int in range(path.size() - 1):
		var a: Vector2 = path[i]
		var b: Vector2 = path[i + 1]
		if (a.y - z) * (b.y - z) <= 0.0 and not is_equal_approx(a.y, b.y):
			return lerpf(a.x, b.x, (z - a.y) / (b.y - a.y))
	return NAN


## Horizontal distance from a point (x, z) to the path.
func distance_to_path(xz: Vector2) -> float:
	var best: float = INF
	for i: int in range(path.size() - 1):
		var a: Vector2 = path[i]
		var ab: Vector2 = path[i + 1] - a
		var t: float = clampf((xz - a).dot(ab) / maxf(ab.length_squared(), 1e-6), 0.0, 1.0)
		best = minf(best, xz.distance_to(a + ab * t))
	return best


## Total length of the path in metres (horizontal).
func path_length() -> float:
	var total: float = 0.0
	for i: int in range(path.size() - 1):
		total += path[i].distance_to(path[i + 1])
	return total


## Piecewise-linear interpolation over points already sorted by X (here: z).
static func _interpolate(pts: PackedVector2Array, at: float) -> float:
	if pts.is_empty():
		return 0.0
	if at <= pts[0].x:
		return pts[0].y
	for i: int in range(pts.size() - 1):
		var a: Vector2 = pts[i]
		var b: Vector2 = pts[i + 1]
		if at <= b.x:
			var t: float = 0.0 if is_equal_approx(a.x, b.x) else (at - a.x) / (b.x - a.x)
			return lerpf(a.y, b.y, t)
	return pts[pts.size() - 1].y


static func _sorted(points: PackedVector2Array) -> PackedVector2Array:
	var arr: Array[Vector2] = []
	for p: Vector2 in points:
		arr.append(p)
	arr.sort_custom(func(a: Vector2, b: Vector2) -> bool: return a.x < b.x)
	return PackedVector2Array(arr)
