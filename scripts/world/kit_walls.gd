class_name KitWalls
extends RefCounted
## Modular kit v1, stone pieces (F3 task 5; docs/guia-visual.md): terrace walls with a
## coping of flat slabs, boundary walls, wall ends, stone stairs, a corral, an irrigation
## channel and the small stones that edge the path. One ArrayMesh per piece (one draw
## call), vertex-coloured from the palette. Walls run along +X from x = 0, base at y = 0.

const COPING_HEIGHT: float = 0.12
const BOUNDARY_THICKNESS: float = 0.5
const CHANNEL_WIDTH: float = 0.45


## Retaining wall of a terrace: pirca topped with flat slabs that jut out a little on
## the front (+Z, downhill) face.
static func terrace_wall(
	length: float, height: float, thickness: float, seed: int, p: PaletteTuning
) -> ArrayMesh:
	var rng := _rng(seed)
	var parts: Array[Array] = []
	var body_h: float = maxf(height - COPING_HEIGHT, 0.1)
	parts.append(
		[
			LowPolyMesh.pirca_wall(length, body_h, thickness, seed, p.stone_light, p.stone_dark),
			Transform3D.IDENTITY
		]
	)
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var x: float = 0.0
	while x < length:
		var w: float = minf(rng.randf_range(0.5, 0.9), length - x)
		if w > 0.15:
			var tint: Color = p.stone_light.lerp(p.stone_dark, rng.randf_range(0.0, 0.5))
			LowPolyMesh.add_box(
				st,
				Vector3(x + w * 0.5, body_h + COPING_HEIGHT * 0.5, 0.06),
				Vector3(w - 0.03, COPING_HEIGHT, thickness + 0.12),
				tint,
				rng,
				0.025
			)
		x += w
	parts.append([st.commit(), Transform3D.IDENTITY])
	return merge(parts)


## Low field or boundary wall topped with rounded stones.
static func boundary_wall(length: float, height: float, seed: int, p: PaletteTuning) -> ArrayMesh:
	var rng := _rng(seed)
	var body_h: float = maxf(height - 0.18, 0.2)
	var parts: Array[Array] = [
		[
			LowPolyMesh.pirca_wall(
				length, body_h, BOUNDARY_THICKNESS, seed, p.stone_light, p.stone_dark
			),
			Transform3D.IDENTITY
		]
	]
	var x: float = 0.15
	while x < length - 0.1:
		var r: float = rng.randf_range(0.14, 0.22)
		var tint: Color = p.stone_light.lerp(p.stone_dark, rng.randf())
		var stone: ArrayMesh = LowPolyMesh.rock(r, 0.8, seed + int(x * 10.0), tint, 0.2)
		parts.append([stone, Transform3D(Basis(), Vector3(x, body_h - 0.04, 0))])
		x += r * 1.7
	return merge(parts)


## End of a wall or side of an opening: big stones stacked, alternating.
static func wall_end(height: float, thickness: float, seed: int, p: PaletteTuning) -> ArrayMesh:
	var rng := _rng(seed)
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var y: float = 0.0
	var i: int = 0
	# Low walls get smaller end stones: a 0.7 m block on a 0.5 m wall reads as a crate.
	var k: float = clampf(height / 1.6, 0.45, 1.0)
	while y < height - 0.05:
		var h: float = minf(rng.randf_range(0.35, 0.5) * k, height - y)
		var w: float = rng.randf_range(0.6, 0.8) * k
		var tint: Color = p.stone_light.lerp(p.stone_dark, rng.randf())
		var off: float = 0.05 if i % 2 == 0 else -0.05
		LowPolyMesh.add_box(
			st,
			Vector3(off, y + h * 0.5, 0),
			Vector3(w, h - 0.02, thickness * 1.15),
			tint,
			rng,
			0.05
		)
		y += h
		i += 1
	return st.commit()


## Stone stairs climbing `drop` towards -Z: bottom edge at z = run, top edge at z = 0.
## Each step is two or three stones side by side, so the treads look laid by hand.
static func stairs(
	drop: float, width: float, rise: float, run: float, seed: int, p: PaletteTuning
) -> ArrayMesh:
	var rng := _rng(seed)
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var count: int = maxi(1, ceili(drop / rise))
	var step_rise: float = drop / count
	for k: int in count:
		var top: float = step_rise * (k + 1)
		var z_far: float = (count - k) * run
		var stones: int = 2 + rng.randi_range(0, 1)
		var x0: float = -width * 0.5
		for s: int in stones:
			var w: float = width / stones
			var tint: Color = p.stone_light.lerp(p.stone_dark, rng.randf())
			LowPolyMesh.add_box(
				st,
				Vector3(x0 + w * (s + 0.5), top * 0.5, z_far - run * 0.5),
				Vector3(w - 0.03, top, run + 0.02),
				tint,
				rng,
				0.025
			)
	return st.commit()


## Irrigation channel along +X: two lines of stones with a dark wet bed between them.
static func channel(length: float, seed: int, p: PaletteTuning) -> ArrayMesh:
	var rng := _rng(seed)
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var half: float = CHANNEL_WIDTH * 0.5
	for side: float in [-1.0, 1.0]:
		var x: float = 0.0
		while x < length:
			var w: float = minf(rng.randf_range(0.3, 0.5), length - x)
			var tint: Color = p.stone_light.lerp(p.stone_dark, rng.randf())
			LowPolyMesh.add_box(
				st,
				Vector3(x + w * 0.5, 0.11, side * (half + 0.1)),
				Vector3(w - 0.02, 0.22, 0.2),
				tint,
				rng,
				0.03
			)
			x += w
	LowPolyMesh.add_box(
		st, Vector3(length * 0.5, 0.03, 0), Vector3(length, 0.06, CHANNEL_WIDTH), p.water, rng, 0.0
	)
	return st.commit()


## Round corral of low pirca with an opening facing +Z, `gap_deg` wide, centred on the
## origin.
static func corral(
	radius: float, height: float, gap_deg: float, seed: int, p: PaletteTuning
) -> ArrayMesh:
	var parts: Array[Array] = []
	var i: int = 0
	for seg: Array in corral_segments(radius, gap_deg):
		parts.append([boundary_wall(seg[1], height, seed + i, p), seg[0]])
		i += 1
	var half_gap: float = deg_to_rad(gap_deg) * 0.5
	for side: float in [-1.0, 1.0]:
		var a: float = side * half_gap
		var at := Vector3(sin(a), 0, cos(a)) * radius
		parts.append(
			[
				wall_end(height + 0.1, BOUNDARY_THICKNESS, seed + 90, p),
				Transform3D(Basis(Vector3.UP, a), at)
			]
		)
	return merge(parts)


## Wall segments of a corral: [Transform3D at the segment start, length] each. Angle 0
## points to +Z; segments inside the opening are left out.
static func corral_segments(radius: float, gap_deg: float) -> Array[Array]:
	var out: Array[Array] = []
	var count: int = maxi(6, ceili(TAU * radius / 2.2))
	var half_gap: float = deg_to_rad(gap_deg) * 0.5
	for i: int in count:
		var a0: float = TAU * i / count
		var a1: float = TAU * (i + 1) / count
		if absf(wrapf((a0 + a1) * 0.5, -PI, PI)) < half_gap:
			continue
		var from := Vector3(sin(a0), 0, cos(a0)) * radius
		var to := Vector3(sin(a1), 0, cos(a1)) * radius
		var xf := Transform3D(Basis(Vector3.UP, atan2(-(to.z - from.z), to.x - from.x)), from)
		out.append([xf, from.distance_to(to)])
	return out


## Small stone for path edges and scatter (drawn with MultiMesh).
static func pebble(seed: int, p: PaletteTuning) -> ArrayMesh:
	return LowPolyMesh.rock(0.16, 0.7, seed, p.stone_light.lerp(p.stone_dark, 0.4), 0.3)


## Merges meshes, each with its transform, into one mesh (one draw call).
static func merge(parts: Array[Array]) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for part: Array in parts:
		var mesh: ArrayMesh = part[0]
		if mesh.get_surface_count() > 0:
			st.append_from(mesh, 0, part[1] as Transform3D)
	return st.commit()


static func _rng(seed: int) -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	return rng
