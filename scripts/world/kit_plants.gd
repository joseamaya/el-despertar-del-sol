class_name KitPlants
extends RefCounted
## Plants of the puna for the scenery (F3 task 8): ichu tufts and low dry shrubs. Tiny
## meshes meant for MultiMesh: an ichu tuft is a fan of 7 thin blades (14 triangles),
## a shrub a lumpy dome (~30 triangles). Blades use up-facing normals so both sides
## shade like the ground they grow on.

const BLADES: int = 9
const DOME_SIDES: int = 6


## An ichu tuft about `height` m tall: blades leaning out from a common base.
static func ichu_tuft(height: float, seed: int, p: PaletteTuning) -> ArrayMesh:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i: int in BLADES:
		var angle: float = TAU * i / BLADES + rng.randf_range(-0.3, 0.3)
		var out := Vector3(cos(angle), 0, sin(angle))
		var side := Vector3(-out.z, 0, out.x)
		var h: float = height * rng.randf_range(0.75, 1.15)
		var lean: float = rng.randf_range(0.25, 0.55) * h
		var root: Vector3 = out * 0.05
		var tip: Vector3 = out * lean + Vector3.UP * h
		var width: float = 0.075
		var base: Color = p.ichu_grass.lerp(p.dry_grass, rng.randf_range(0.0, 0.35)).darkened(0.12)
		var top: Color = p.ichu_grass.lightened(rng.randf_range(0.12, 0.3))
		# Two triangles per blade: a narrow base that ends in a point.
		_vertex(st, root - side * width, base.darkened(0.25))
		_vertex(st, root + side * width, base.darkened(0.25))
		_vertex(st, tip, top)
		_vertex(st, root + side * width, base.darkened(0.25))
		_vertex(st, root + out * 0.04 + Vector3.UP * h * 0.3, base)
		_vertex(st, tip, top)
	return st.commit()


## A low shrub: a dome of `radius` with a lumpy outline, base on y = 0.
static func shrub(radius: float, seed: int, p: PaletteTuning) -> ArrayMesh:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var st := LowPolyMesh.begin()
	var ring := PackedVector3Array()
	var mid := PackedVector3Array()
	for i: int in DOME_SIDES:
		var a: float = TAU * i / DOME_SIDES
		var r: float = radius * rng.randf_range(0.8, 1.15)
		ring.append(Vector3(cos(a) * r, 0.0, sin(a) * r))
		mid.append(
			Vector3(
				cos(a + 0.5) * r * 0.75,
				radius * rng.randf_range(0.45, 0.65),
				sin(a + 0.5) * r * 0.75
			)
		)
	var top := Vector3(rng.randf_range(-0.1, 0.1), radius * 0.85, rng.randf_range(-0.1, 0.1))
	for i: int in DOME_SIDES:
		var j: int = (i + 1) % DOME_SIDES
		var tint: Color = p.shrub.lerp(p.dry_grass, rng.randf_range(0.0, 0.3))
		var out_low := (ring[i] + ring[j] + mid[i]) / 3.0
		LowPolyMesh.add_tri(st, ring[i], ring[j], mid[i], tint, out_low)
		LowPolyMesh.add_tri(
			st, ring[j], mid[j], mid[i], tint.darkened(0.06), (ring[j] + mid[j] + mid[i]) / 3.0
		)
		LowPolyMesh.add_tri(
			st,
			mid[i],
			mid[j],
			top,
			tint.lightened(0.05),
			(mid[i] + mid[j] + top) / 3.0 - Vector3(0, radius * 0.2, 0)
		)
	return LowPolyMesh.end(st)


static func _vertex(st: SurfaceTool, at: Vector3, colour: Color) -> void:
	st.set_color(colour)
	st.set_normal(Vector3.UP)
	st.add_vertex(at)
