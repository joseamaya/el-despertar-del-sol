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
## The steep sides rise only this high (enough to block the player) and then roll on as
## gentle hills at `side_far_grade`, instead of walls up to the sector edge (F3 task 11:
## the sides read as cliffs). 0 = no cap.
@export_range(0.0, 100.0, 0.5, "suffix:m") var side_max_rise: float = 0.0
@export_range(0.0, 1.0, 0.01) var side_far_grade: float = 0.15
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
## Whether the sector has the huaca and the family's llamas (F8 task 11: the prologue and
## the hub have neither; before, both were built at the origin, on the path).
@export var has_huaca: bool = true
@export var has_llamas: bool = true
@export var huaca: Vector2 = Vector2.ZERO
## A thread of smoke from the offering at the huaca, so it can be found from the path
## (F4 task 6): where it rises from (offset from the huaca) and how high. 0: none.
@export var huaca_smoke_offset: Vector2 = Vector2(0.6, 1.8)
@export_range(0.0, 30.0, 0.5, "suffix:m") var huaca_smoke_height: float = 0.0
## Slice story points (F4 task 2): where the family asks for help (Apoyo) and where the
## slice ends.
@export var family: Vector2 = Vector2.ZERO
## The family's llamas, in a corral past the houses (F4 task 6): the corral's centre
## (its corral is the one in `corrals` at this point).
@export var llamas: Vector2 = Vector2.ZERO
## Where Vicaquirao waits at the opening (F4 task 3); he faces the valley.
@export var mentor: Vector2 = Vector2.ZERO
@export var ending: Vector2 = Vector2.ZERO
## Where Cusi looks at the end of the slice: Cusco down in the valley (F4 task 7). Far
## outside the sector; only its marker is built.
@export var cusco_view: Vector2 = Vector2.ZERO
## More named markers (F8 task 8): in the hub, where Apo Mayta and the curacas stand. (x, z).
@export var points: Dictionary[StringName, Vector2] = {}
## Respawn points after a defeat, in the order they are reached; they face uphill.
@export var checkpoints: PackedVector2Array = PackedVector2Array()
## Encounter zones: (x, z, radius). Order: skirmish 1, skirmish 2, the pass.
@export var encounters: PackedVector3Array = PackedVector3Array()
## Enemies waiting in each encounter zone (same order as `encounters`).
@export var encounter_enemies: PackedInt32Array = PackedInt32Array()
## Reinforcements of each encounter zone (same order): (x, z, count). They come from
## (x, z), uphill, once the zone's first warriors have fallen (F4 task 12b).
@export var encounter_reinforcements: PackedVector3Array = PackedVector3Array()
## Scouts that walk a route instead of waiting (F9 task 12): by spawn index (the waiting
## warriors of every zone, counted in order), the route's points (x, z). The warrior starts
## at its spawn point and walks the route in a loop.
@export var patrols: Dictionary[int, PackedVector2Array] = {}
## Houses: (x, z, yaw in degrees).
@export var houses: PackedVector3Array = PackedVector3Array()
## House sizes (x width, y wall height, z depth): the common one and the bigger one of the
## houses listed in `big_houses` (F9 task 4: the hub's main houses), by index in `houses`.
@export var house_size: Vector3 = Vector3(4.5, 2.2, 3.6)
@export var big_house_size: Vector3 = Vector3(7.0, 2.6, 4.2)
@export var big_houses: PackedInt32Array = PackedInt32Array()
## Houses left shut by the families who fled (the door walled up with stones), by index.
@export var closed_houses: PackedInt32Array = PackedInt32Array()
## Stone posts at the sides of an opening in a wall, such as a kancha's gate: (x, z, yaw in
## degrees; yaw 0 runs the post along X).
@export var gate_posts: PackedVector3Array = PackedVector3Array()
@export_range(0.5, 3.0, 0.05, "suffix:m") var gate_post_height: float = 1.7
## Houses beyond the walkable ground (F9: the city goes on past the hub): (x, z, yaw in
## degrees). Drawn only, without collider or shadow; they stand where Cusi cannot go.
@export var outskirts: PackedVector3Array = PackedVector3Array()
## Huacas that only stand there, without the slice's offering (F9 task 4: the one in the
## hub's square): (x, z, yaw in degrees; the opening of the ring faces +Z at yaw 0).
@export var shrines: PackedVector3Array = PackedVector3Array()
## Corrals: (x, z, radius); opening downhill (+Z).
@export var corrals: PackedVector3Array = PackedVector3Array()
## Crags framing the pass: (x, z, height).
@export var crags: PackedVector3Array = PackedVector3Array()
## Traces of the people who fled (F4 task 12c): (x, z, yaw in degrees, KitProps.Kind).
@export var props: PackedVector4Array = PackedVector4Array()
## Height of the thin smoke still rising from each hearth (0: none).
@export_range(0.0, 10.0, 0.5, "suffix:m") var hearth_smoke_height: float = 0.0
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


## Size of house `index` in `houses`.
func house_size_at(index: int) -> Vector3:
	return big_house_size if big_houses.has(index) else house_size


## True if `xz` is within `reach` of one of the `shrines` (to keep scatter out of them).
func near_shrine(xz: Vector2, reach: float) -> bool:
	for s: Vector3 in shrines:
		if xz.distance_to(Vector2(s.x, s.y)) < reach:
			return true
	return false


## Ground height at a local point: profile along Z plus the steep sides.
func height_at(x: float, z: float) -> float:
	var h: float = profile_at(z)
	var half: float = corridor_half_width(z)
	return h + side_rise(absf(x) - half)


## Height of the side above the profile, `outside` metres beyond the corridor edge.
func side_rise(outside: float) -> float:
	if outside <= 0.0:
		return 0.0
	if side_max_rise <= 0.0:
		return outside * side_grade
	var steep_run: float = side_max_rise / side_grade
	if outside <= steep_run:
		return outside * side_grade
	return side_max_rise + (outside - steep_run) * side_far_grade


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
