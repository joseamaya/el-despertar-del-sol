class_name SectorDressing
extends RefCounted
## Dresses a built sector with kit pieces that are not structure (F3 task 5): corrals,
## the irrigation channel, crags at the pass, scattered rocks and the stones edging the
## path. Repeated pieces go through MultiMesh (one draw call per kind of rock).

const EDGE_SPACING: float = 0.9
## Keep scatter this far from the path, walls, houses and the huaca (m).
const CLEAR_PATH: float = 3.0
const CLEAR_STEP: float = 2.5
const CLEAR_HOUSE: float = 5.5
const CLEAR_HUACA: float = 4.5
## Share of rocks placed on the steep sides, outside the corridor.
const SIDE_SHARE: float = 0.35


static func dress(root: Node3D, layout: SectorLayout, palette: PaletteTuning) -> void:
	var i: int = 0
	for c: Vector3 in layout.corrals:
		_corral(root, layout, palette, c, i)
		i += 1
	for c: Vector3 in layout.crags:
		_crag(root, layout, palette, c, i)
		i += 1
	if layout.channel.size() >= 2:
		_channel(root, layout, palette)
	_scatter_rocks(root, layout, palette)
	_edge_path(root, layout, palette)


static func _corral(
	root: Node3D, layout: SectorLayout, p: PaletteTuning, c: Vector3, i: int
) -> void:
	var at := Vector3(c.x, layout.height_at(c.x, c.y), c.y)
	var gap: float = 40.0
	SectorBuilder.add_mesh(root, "Corral%d" % i, KitWalls.corral(c.z, 1.0, gap, 60 + i, p), p, at)
	for seg: Array in KitWalls.corral_segments(c.z, gap):
		var xf: Transform3D = seg[0]
		var length: float = seg[1]
		var mid: Vector3 = at + xf.origin + xf.basis.x * length * 0.5 + Vector3.UP * 0.5
		var body := SectorBuilder.add_box_collider(root, mid, Vector3(length, 1.0, 0.5))
		body.basis = xf.basis


static func _crag(root: Node3D, layout: SectorLayout, p: PaletteTuning, c: Vector3, i: int) -> void:
	# Crags stand on the steep sides: sink them so no part floats over the corridor.
	var at := Vector3(c.x, layout.height_at(c.x, c.y) - c.z * 0.3, c.y)
	SectorBuilder.add_mesh(root, "Crag%d" % i, KitBuildings.crag(c.z, 70 + i, p), p, at)
	var body := SectorBuilder.static_body(root, "CragBody%d" % i)
	body.position = at + Vector3.UP * c.z * 0.5
	var col := CollisionShape3D.new()
	var cyl := CylinderShape3D.new()
	cyl.radius = c.z / 2.7 * 1.1
	cyl.height = c.z
	col.shape = cyl
	body.add_child(col)


static func _channel(root: Node3D, layout: SectorLayout, p: PaletteTuning) -> void:
	var parts: Array[Array] = []
	for i: int in range(layout.channel.size() - 1):
		var a: Vector2 = layout.channel[i]
		var b: Vector2 = layout.channel[i + 1]
		var length: float = a.distance_to(b)
		var angle: float = atan2(-(b.y - a.y), b.x - a.x)
		var at := Vector3(a.x, layout.height_at(a.x, a.y), a.y)
		parts.append(
			[KitWalls.channel(length, 80 + i, p), Transform3D(Basis(Vector3.UP, angle), at)]
		)
	SectorBuilder.add_mesh(root, "Channel", KitWalls.merge(parts), p, Vector3.ZERO)


static func _scatter_rocks(root: Node3D, layout: SectorLayout, p: PaletteTuning) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = layout.rock_seed
	var steps: PackedVector3Array = layout.terrace_steps()
	var by_size: Array[Array] = [[], [], []]
	var tries: int = 0
	var placed: int = 0
	var half: Vector2 = layout.size * 0.5 - Vector2(4, 4)
	while placed < layout.rock_count and tries < layout.rock_count * 20:
		tries += 1
		var xz := Vector2(rng.randf_range(-half.x, half.x), rng.randf_range(-half.y, half.y))
		var corridor: float = layout.corridor_half_width(xz.y)
		var on_side: bool = absf(xz.x) > corridor
		if on_side and (rng.randf() > SIDE_SHARE or absf(xz.x) > corridor + 25.0):
			continue
		var size: int = _pick_size(rng, on_side)
		if not _clear(layout, steps, xz, size):
			continue
		var basis := Basis(Vector3.UP, rng.randf() * TAU).scaled(
			Vector3.ONE * rng.randf_range(0.7, 1.3)
		)
		# On the steep sides rocks sink deeper so their downhill edge does not float.
		var side_sink: Array[float] = [0.3, 0.8, 1.6]
		var sink: float = 0.1 + (side_sink[size] if on_side else 0.0)
		var at := Vector3(xz.x, layout.height_at(xz.x, xz.y) - sink, xz.y)
		by_size[size].append(Transform3D(basis, at))
		if size == 2 and not on_side:
			var body := SectorBuilder.static_body(root, "RockBody")
			body.position = at + Vector3.UP * 0.6
			var col := CollisionShape3D.new()
			var sphere := SphereShape3D.new()
			sphere.radius = 0.9
			col.shape = sphere
			body.add_child(col)
		placed += 1
	for size: int in 3:
		_multimesh(
			root, "Rocks%d" % size, KitBuildings.loose_rock(size, 90 + size, p), by_size[size], p
		)


static func _pick_size(rng: RandomNumberGenerator, on_side: bool) -> int:
	var roll: float = rng.randf()
	if on_side:
		return 2 if roll < 0.35 else (1 if roll < 0.8 else 0)
	return 0 if roll < 0.6 else (1 if roll < 0.9 else 2)


## True if a rock of `size` at `xz` leaves the path, stairs, houses, huaca and (for
## medium and large rocks) the encounter zones free.
static func _clear(layout: SectorLayout, steps: PackedVector3Array, xz: Vector2, size: int) -> bool:
	if layout.distance_to_path(xz) < CLEAR_PATH + size:
		return false
	for s: Vector3 in steps:
		if absf(xz.y - (s.x - 0.5)) < CLEAR_STEP:
			return false
	for h: Vector3 in layout.houses:
		if xz.distance_to(Vector2(h.x, h.y)) < CLEAR_HOUSE:
			return false
	for c: Vector3 in layout.corrals:
		if absf(xz.distance_to(Vector2(c.x, c.y)) - c.z) < 1.5:
			return false
	if xz.distance_to(layout.huaca) < CLEAR_HUACA:
		return false
	if size > 0:
		for e: Vector3 in layout.encounters:
			if xz.distance_to(Vector2(e.x, e.y)) < e.z + 1.0:
				return false
	return true


static func _edge_path(root: Node3D, layout: SectorLayout, p: PaletteTuning) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 404
	var steps: PackedVector3Array = layout.terrace_steps()
	var transforms: Array = []
	var offset: float = layout.path_width * 0.5 + 0.12
	for i: int in range(layout.path.size() - 1):
		var a: Vector2 = layout.path[i]
		var b: Vector2 = layout.path[i + 1]
		var dir: Vector2 = (b - a).normalized()
		var side := Vector2(-dir.y, dir.x)
		var count: int = int(a.distance_to(b) / EDGE_SPACING)
		for k: int in count:
			var c: Vector2 = a.lerp(b, (k + 0.5) / count)
			var near_step: bool = false
			for s: Vector3 in steps:
				near_step = near_step or absf(c.y - (s.x - 0.5)) < 3.0
			if near_step or rng.randf() < 0.15:
				continue
			for sgn: float in [-1.0, 1.0]:
				var xz: Vector2 = c + side * sgn * (offset + rng.randf_range(-0.08, 0.12))
				var at := Vector3(xz.x, layout.height_at(xz.x, xz.y) - 0.04, xz.y)
				var basis := Basis(Vector3.UP, rng.randf() * TAU).scaled(
					Vector3.ONE * rng.randf_range(0.8, 1.25)
				)
				transforms.append(Transform3D(basis, at))
	_multimesh(root, "PathEdge", KitWalls.pebble(5, p), transforms, p)


static func _multimesh(
	root: Node3D, node_name: String, mesh: ArrayMesh, transforms: Array, p: PaletteTuning
) -> void:
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = mesh
	mm.instance_count = transforms.size()
	for i: int in transforms.size():
		mm.set_instance_transform(i, transforms[i] as Transform3D)
	var node := MultiMeshInstance3D.new()
	node.name = node_name
	node.multimesh = mm
	node.material_override = PaletteMaterials.material_for(p, PaletteMaterials.Role.VERTEX)
	root.add_child(node)
