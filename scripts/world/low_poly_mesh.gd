class_name LowPolyMesh
extends RefCounted
## Faceted low-poly meshes for the scenery, built by code (DECISIONS/0010): dry-stone
## pirca walls, adobe walls, ichu roofs and rocks, plus the triangle helpers every
## generator uses. Flat normals, vertex colours, deterministic for a given seed.
## Ground and mountains live in LowPolyTerrain.

## Pirca stones: width, height and depth ranges (m) and corner jitter.
const STONE_WIDTH: Vector2 = Vector2(0.35, 0.7)
const STONE_HEIGHT: Vector2 = Vector2(0.22, 0.38)
const STONE_JITTER: float = 0.06


## A dry-stone wall along +X from x = 0 to `length`, base at y = 0, centred on z = 0.
## Stones are irregular boxes laid in courses; each stone gets a colour between
## `light` and `dark`.
static func pirca_wall(
	length: float, height: float, thickness: float, seed: int, light: Color, dark: Color
) -> ArrayMesh:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var st := begin()
	var y: float = 0.0
	var course: int = 0
	while y < height - 0.05:
		var h: float = minf(rng.randf_range(STONE_HEIGHT.x, STONE_HEIGHT.y), height - y)
		var x: float = 0.0 if course % 2 == 0 else -rng.randf_range(0.1, 0.25)
		while x < length:
			var w: float = rng.randf_range(STONE_WIDTH.x, STONE_WIDTH.y)
			var x0: float = maxf(x, 0.0)
			var x1: float = minf(x + w, length)
			if x1 - x0 > 0.08:
				var centre := Vector3((x0 + x1) * 0.5, y + h * 0.5, rng.randf_range(-0.03, 0.03))
				var size := Vector3(x1 - x0 - 0.02, h - 0.02, thickness)
				var tint: Color = light.lerp(dark, rng.randf())
				add_box(st, centre, size, tint, rng, STONE_JITTER)
			x += w
		y += h
		course += 1
	return end(st)


## A plain box (adobe wall, terrace fill) with optional corner jitter for a hand-made look.
static func box(size: Vector3, colour: Color, seed: int = 0, jitter: float = 0.0) -> ArrayMesh:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var st := begin()
	add_box(st, Vector3(0.0, size.y * 0.5, 0.0), size, colour, rng, jitter)
	return end(st)


## Adobe walls of a one-room house: `size` outside (x width, y wall height, z depth),
## walls `thickness` thick, one door centred on the +Z wall.
static func adobe_house_walls(
	size: Vector3, thickness: float, door: Vector2, colour: Color, seed: int
) -> ArrayMesh:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var st := begin()
	var hx: float = size.x * 0.5
	var hz: float = size.z * 0.5
	var j: float = 0.03
	add_box(
		st,
		Vector3(0, size.y * 0.5, -hz + thickness * 0.5),
		Vector3(size.x, size.y, thickness),
		colour,
		rng,
		j
	)
	add_box(
		st,
		Vector3(-hx + thickness * 0.5, size.y * 0.5, 0),
		Vector3(thickness, size.y, size.z - thickness * 2.0),
		colour,
		rng,
		j
	)
	add_box(
		st,
		Vector3(hx - thickness * 0.5, size.y * 0.5, 0),
		Vector3(thickness, size.y, size.z - thickness * 2.0),
		colour,
		rng,
		j
	)
	var side: float = (size.x - door.x) * 0.5
	var front_z: float = hz - thickness * 0.5
	add_box(
		st,
		Vector3(-hx + side * 0.5, size.y * 0.5, front_z),
		Vector3(side, size.y, thickness),
		colour,
		rng,
		j
	)
	add_box(
		st,
		Vector3(hx - side * 0.5, size.y * 0.5, front_z),
		Vector3(side, size.y, thickness),
		colour,
		rng,
		j
	)
	var lintel: float = size.y - door.y
	add_box(
		st,
		Vector3(0, door.y + lintel * 0.5, front_z),
		Vector3(door.x, lintel, thickness),
		colour,
		rng,
		j
	)
	return end(st)


## A thick gable (two-slope) thatch roof over a `width` × `depth` footprint, ridge along
## Z, eaves at y = 0, ridge at `rise`. `overhang` extends it past the walls on all sides.
static func gable_roof(
	width: float, depth: float, rise: float, overhang: float, colour: Color
) -> ArrayMesh:
	var st := begin()
	var hx: float = width * 0.5 + overhang
	var hz: float = depth * 0.5 + overhang
	var thick: float = 0.25
	var drop: float = overhang * rise / (width * 0.5)
	for zs: float in [-1.0, 1.0]:
		var z: float = hz * zs
		# Gable ends (triangles) closing each end of the roof.
		add_tri(
			st,
			Vector3(-hx, -drop, z),
			Vector3(hx, -drop, z),
			Vector3(0, rise, z),
			colour,
			Vector3(0, 0, zs)
		)
	for xs: float in [-1.0, 1.0]:
		var eave := Vector3(hx * xs, -drop, 0)
		var top := Vector3(0, rise, 0)
		var out := Vector3(xs * rise, width * 0.5, 0).normalized()
		add_quad(
			st,
			eave + Vector3(0, 0, -hz),
			eave + Vector3(0, 0, hz),
			top + Vector3(0, 0, hz),
			top + Vector3(0, 0, -hz),
			colour,
			out
		)
		# Underside, a bit darker, so the thatch reads thick from below.
		var under := Vector3(0, -thick, 0)
		add_quad(
			st,
			eave + under + Vector3(0, 0, -hz),
			top + under + Vector3(0, 0, -hz),
			top + under + Vector3(0, 0, hz),
			eave + under + Vector3(0, 0, hz),
			colour.darkened(0.35),
			-out
		)
		add_quad(
			st,
			eave + Vector3(0, 0, -hz),
			eave + under + Vector3(0, 0, -hz),
			eave + under + Vector3(0, 0, hz),
			eave + Vector3(0, 0, hz),
			colour.darkened(0.2),
			Vector3(xs, -0.3, 0).normalized()
		)
	return end(st)


## A faceted rock: a low-poly sphere of `radius` with its surface pushed in and out.
## `squash` scales Y (below 1 = flatter). Base sits roughly on y = 0.
static func rock(
	radius: float, squash: float, seed: int, colour: Color, roughness: float = 0.25
) -> ArrayMesh:
	var sphere := SphereMesh.new()
	sphere.radius = radius
	sphere.height = radius * 2.0
	sphere.radial_segments = 9
	sphere.rings = 5
	var arrays: Array = sphere.get_mesh_arrays()
	var verts: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	var index: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
	var st := begin()
	for i: int in range(0, index.size(), 3):
		var a: Vector3 = _rock_point(verts[index[i]], radius, squash, seed, roughness)
		var b: Vector3 = _rock_point(verts[index[i + 1]], radius, squash, seed, roughness)
		var c: Vector3 = _rock_point(verts[index[i + 2]], radius, squash, seed, roughness)
		add_tri(st, a, b, c, colour, (a + b + c) / 3.0 - Vector3(0, radius * squash * 0.85, 0))
	return end(st)


## Adds a box with each of its 8 corners nudged by up to `jitter` (m).
static func add_box(
	st: SurfaceTool,
	centre: Vector3,
	size: Vector3,
	colour: Color,
	rng: RandomNumberGenerator,
	jitter: float
) -> void:
	var h: Vector3 = size * 0.5
	var c := PackedVector3Array()
	for i: int in 8:
		var corner := Vector3(
			h.x if i & 1 else -h.x, h.y if i & 2 else -h.y, h.z if i & 4 else -h.z
		)
		var nudge := Vector3(
			rng.randf_range(-jitter, jitter),
			rng.randf_range(-jitter, jitter),
			rng.randf_range(-jitter, jitter)
		)
		c.append(centre + corner + nudge)
	var faces: Array[PackedInt32Array] = [
		PackedInt32Array([0, 2, 6, 4]),
		PackedInt32Array([1, 5, 7, 3]),
		PackedInt32Array([0, 4, 5, 1]),
		PackedInt32Array([2, 3, 7, 6]),
		PackedInt32Array([0, 1, 3, 2]),
		PackedInt32Array([4, 6, 7, 5]),
	]
	for f: PackedInt32Array in faces:
		var mid: Vector3 = (c[f[0]] + c[f[1]] + c[f[2]] + c[f[3]]) / 4.0
		add_quad(st, c[f[0]], c[f[1]], c[f[2]], c[f[3]], colour, mid - centre)


## Adds a quad as two triangles facing `outward`.
static func add_quad(
	st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, d: Vector3, colour: Color, outward: Vector3
) -> void:
	add_tri(st, a, b, c, colour, outward)
	add_tri(st, a, c, d, colour, outward)


## Adds one flat-shaded triangle whose front face looks along `outward`. Godot draws a
## triangle's front when (b - a) × (c - a) points away from the viewer.
static func add_tri(
	st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, colour: Color, outward: Vector3
) -> void:
	var n: Vector3 = (b - a).cross(c - a)
	if n.length_squared() < 1e-12:
		return
	if n.dot(outward) > 0.0:
		var t: Vector3 = b
		b = c
		c = t
		n = -n
	var normal: Vector3 = -n.normalized()
	for p: Vector3 in [a, b, c]:
		st.set_color(colour)
		st.set_normal(normal)
		st.add_vertex(p)


static func _rock_point(
	v: Vector3, radius: float, squash: float, seed: int, roughness: float
) -> Vector3:
	# Deterministic per direction, so seam duplicates of a vertex move together.
	var dir: Vector3 = v.normalized() if v.length_squared() > 0.0 else Vector3.UP
	var h: float = (
		sin(dir.x * 12.9898 + dir.y * 78.233 + dir.z * 37.719 + seed * 0.618) * 43758.5453
	)
	var bump: float = 1.0 + (h - floorf(h) - 0.5) * 2.0 * roughness
	var p: Vector3 = dir * radius * bump
	return Vector3(p.x, (p.y + radius) * squash, p.z)


static func begin() -> SurfaceTool:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	return st


static func end(st: SurfaceTool) -> ArrayMesh:
	return st.commit()
