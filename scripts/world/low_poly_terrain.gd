class_name LowPolyTerrain
extends RefCounted
## Faceted ground and mountains (apus), split from LowPolyMesh (scene audit, F3 task 5).
## Heights come from a Callable so the same code builds the sector, the valley and the
## style tests; colours can too (fields, aerial perspective).


## A mountain (apu): an irregular cone 1 m wide at the base (radius 1) and 1 m high,
## to be scaled. Wide base, broken shoulders and a peak off-centre.
static func mountain(seed: int, colour: Color) -> ArrayMesh:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var sides: int = 11
	var rings: Array[PackedVector3Array] = []
	var heights: Array[float] = [0.0, 0.35, 0.7]
	var radii: Array[float] = [1.0, 0.62, 0.28]
	var lean := Vector3(rng.randf_range(-0.15, 0.15), 0.0, rng.randf_range(-0.1, 0.1))
	for r: int in heights.size():
		var ring := PackedVector3Array()
		for i: int in sides:
			var angle: float = TAU * i / sides
			var radius: float = radii[r] * rng.randf_range(0.8, 1.15)
			var y: float = heights[r] + (rng.randf_range(-0.06, 0.06) if r > 0 else 0.0)
			ring.append(Vector3(cos(angle) * radius, y, sin(angle) * radius) + lean * heights[r])
		rings.append(ring)
	var peak := Vector3(0.0, 1.0, 0.0) + lean
	var st := LowPolyMesh.begin()
	var shade: Color = colour
	for r: int in rings.size():
		for i: int in sides:
			var a: Vector3 = rings[r][i]
			var b: Vector3 = rings[r][(i + 1) % sides]
			var tint: Color = shade.lightened(rng.randf_range(0.0, 0.08))
			if r + 1 < rings.size():
				var c: Vector3 = rings[r + 1][(i + 1) % sides]
				var d: Vector3 = rings[r + 1][i]
				var out := Vector3(a.x + b.x, 0.0, a.z + b.z)
				LowPolyMesh.add_quad(st, a, b, c, d, tint, out)
			else:
				LowPolyMesh.add_tri(st, a, b, peak, tint, Vector3(a.x + b.x, 0.3, a.z + b.z))
	return LowPolyMesh.end(st)


## A ground patch `size` (x, z) in `cells` per side, heights from `height_at`
## (Callable(Vector2) -> float), coloured between `low` and `high` with some noise.
static func ground(
	size: Vector2, cells: int, height_at: Callable, low: Color, high: Color, seed: int
) -> ArrayMesh:
	return ground_grid(size, Vector2i(cells, cells), height_at, low, high, seed)


## Same as ground() with a different number of cells across X and Z (cells need not be
## square). Heights are sampled once per vertex.
static func ground_grid(
	size: Vector2,
	cells: Vector2i,
	height_at: Callable,
	low: Color,
	high: Color,
	seed: int,
	colour_at: Callable = Callable()
) -> ArrayMesh:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var step := Vector2(size.x / cells.x, size.y / cells.y)
	var origin := -size * 0.5
	var row: int = cells.x + 1
	var grid := PackedVector3Array()
	grid.resize(row * (cells.y + 1))
	for iz: int in cells.y + 1:
		for ix: int in row:
			var xz: Vector2 = origin + Vector2(ix, iz) * step
			grid[iz * row + ix] = Vector3(xz.x, float(height_at.call(xz)), xz.y)
	var st := LowPolyMesh.begin()
	for iz: int in cells.y:
		for ix: int in cells.x:
			var p0: Vector3 = grid[iz * row + ix]
			var p1: Vector3 = grid[iz * row + ix + 1]
			var p2: Vector3 = grid[(iz + 1) * row + ix + 1]
			var p3: Vector3 = grid[(iz + 1) * row + ix]
			var tint: Color = low.lerp(high, rng.randf())
			if colour_at.is_valid():
				var centre: Vector3 = (p0 + p2) * 0.5
				tint = colour_at.call(Vector2(centre.x, centre.z), tint)
			LowPolyMesh.add_tri(st, p0, p1, p2, tint, Vector3.UP)
			LowPolyMesh.add_tri(st, p0, p2, p3, tint.lightened(0.03), Vector3.UP)
	return LowPolyMesh.end(st)
