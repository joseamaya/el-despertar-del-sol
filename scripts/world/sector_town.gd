class_name SectorTown
extends RefCounted
## The pieces of a town that a hillside sector does not have (F9 task 4): stone posts at
## the gates of the kanchas and the huacas that only stand there, without the slice's
## offering. All in one mesh, each with its collider. Also the houses beyond the walkable
## ground, so the city goes on past the hub.

## Thickness of a gate post (a little more than the boundary wall it ends).
const POST_THICKNESS: float = 0.75
## Radius of the pirca ring around a huaca, and the width of its opening.
const RING_RADIUS: float = 2.6
const RING_GAP_DEG: float = 50.0


static func build(root: Node3D, layout: SectorLayout, palette: PaletteTuning) -> void:
	var parts: Array[Array] = []
	var i: int = 0
	for post: Vector3 in layout.gate_posts:
		var xf: Transform3D = _place(layout, post)
		var mesh: ArrayMesh = KitWalls.wall_end(
			layout.gate_post_height, POST_THICKNESS, 300 + i, palette
		)
		parts.append([mesh, xf])
		var size := Vector3(0.8, layout.gate_post_height, POST_THICKNESS)
		var col := SectorBuilder.add_box_collider(root, xf.origin + Vector3.UP * size.y * 0.5, size)
		col.basis = xf.basis
		i += 1
	for shrine: Vector3 in layout.shrines:
		var xf: Transform3D = _place(layout, shrine)
		parts.append([KitBuildings.standing_huaca(400 + i, palette), xf])
		_shrine_colliders(root, xf)
		i += 1
	if not parts.is_empty():
		SectorBuilder.add_mesh(root, "Town", KitWalls.merge(parts), palette, Vector3.ZERO)
	_build_outskirts(root, layout, palette)
	_build_streams(root, layout, palette)


## The houses beyond the walkable ground, in one mesh with no shadow: only seen from afar,
## so they are the kit's far house (F10 task 1), not the full one.
static func _build_outskirts(root: Node3D, layout: SectorLayout, palette: PaletteTuning) -> void:
	if layout.outskirts.is_empty():
		return
	var parts: Array[Array] = []
	var i: int = 0
	for house: Vector3 in layout.outskirts:
		parts.append(
			[KitBuildings.far_house(layout.house_size, 500 + i, palette), _place(layout, house)]
		)
		i += 1
	var node: MeshInstance3D = SectorBuilder.add_mesh(
		root, "Outskirts", KitWalls.merge(parts), palette, Vector3.ZERO
	)
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF


## Where a piece at (x, z, yaw in degrees) stands on the ground.
static func _place(layout: SectorLayout, at: Vector3) -> Transform3D:
	var ground := Vector3(at.x, layout.height_at(at.x, at.y), at.y)
	return Transform3D(Basis(Vector3.UP, deg_to_rad(at.z)), ground)


## The stone and the ring block the way; the opening of the ring stays walkable.
static func _shrine_colliders(root: Node3D, xf: Transform3D) -> void:
	var stone := SectorBuilder.add_box_collider(
		root, xf.origin + Vector3.UP * 1.5, Vector3(1.4, 3.0, 1.4)
	)
	stone.basis = xf.basis
	for seg: Array in KitWalls.corral_segments(RING_RADIUS, RING_GAP_DEG):
		var s: Transform3D = xf * (seg[0] as Transform3D)
		var length: float = seg[1]
		var mid: Vector3 = s.origin + s.basis.x * length * 0.5 + Vector3.UP * 0.3
		var ring := SectorBuilder.add_box_collider(root, mid, Vector3(length, 0.6, 0.5))
		ring.basis = s.basis


## The water of the streams (a ribbon in the bed) and stones along their eaten banks, in one
## mesh; only where Cusi can see them up close (inside the sector's walkable length).
static func _build_streams(root: Node3D, layout: SectorLayout, palette: PaletteTuning) -> void:
	if layout.streams.is_empty():
		return
	var rng := RandomNumberGenerator.new()
	rng.seed = 77
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var half: float = layout.stream_width * 0.35
	for line: PackedVector2Array in layout.streams:
		for i: int in line.size() - 1:
			var a: Vector2 = line[i]
			var b: Vector2 = line[i + 1]
			var pieces: int = maxi(1, ceili(a.distance_to(b) / 2.0))
			var side: Vector2 = (b - a).normalized().orthogonal()
			for k: int in pieces:
				var p0: Vector2 = a.lerp(b, float(k) / pieces)
				var p1: Vector2 = a.lerp(b, float(k + 1) / pieces)
				var q := PackedVector3Array()
				for c: Vector2 in [
					p0 - side * half, p1 - side * half, p1 + side * half, p0 + side * half
				]:
					q.append(Vector3(c.x, layout.profile_at(c.y) - layout.stream_depth + 0.12, c.y))
				LowPolyMesh.add_quad(st, q[0], q[1], q[2], q[3], palette.water, Vector3.UP)
				for s: float in [-1.0, 1.0]:
					if rng.randf() < 0.3:
						var at: Vector2 = (
							p0 + side * s * (layout.stream_width * 0.5 + rng.randf_range(0.0, 0.6))
						)
						var r: float = rng.randf_range(0.12, 0.3)
						var tint: Color = palette.stone_light.lerp(palette.stone_dark, rng.randf())
						var rock: ArrayMesh = LowPolyMesh.rock(r, 0.7, rng.randi(), tint, 0.3)
						var y: float = layout.height_at(at.x, at.y) - r * 0.3
						st.append_from(rock, 0, Transform3D(Basis(), Vector3(at.x, y, at.y)))
	var node: MeshInstance3D = SectorBuilder.add_mesh(
		root, "Streams", st.commit(), palette, Vector3.ZERO
	)
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
