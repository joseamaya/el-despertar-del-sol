class_name SectorVegetation
extends RefCounted
## Plants a sector with ichu and shrubs (F3 task 8), cheap by design: MultiMesh per
## square chunk (off-screen chunks are culled), a visibility range so far plants are not
## drawn, and no shadows for the ichu. Keeps the path, stairs, houses, huaca, corrals and
## the encounter zones clear (combat needs a readable floor).

const ICHU_HEIGHT: float = 0.8
const SHRUB_RADIUS: float = 0.6
## Extra clearance around the path and the encounter zones (m).
const CLEAR_PATH: float = 1.2
const CLEAR_ZONE: float = 1.0
## Variants per kind, so neighbours do not repeat.
const VARIANTS: int = 3


static func plant(root: Node3D, layout: SectorLayout, p: PaletteTuning) -> Node3D:
	var veg := Node3D.new()
	veg.name = "Vegetation"
	root.add_child(veg)
	var ichu: Array[ArrayMesh] = []
	var shrubs: Array[ArrayMesh] = []
	for v: int in VARIANTS:
		ichu.append(KitPlants.ichu_tuft(ICHU_HEIGHT, 100 + v, p))
		shrubs.append(KitPlants.shrub(SHRUB_RADIUS, 200 + v, p))
	for c: Dictionary in placements(layout):
		var v: int = c["variant"]
		_multimesh(veg, "Ichu_%s" % c["name"], ichu[v], c["ichu"], layout, p, false)
		_multimesh(veg, "Shrub_%s" % c["name"], shrubs[v], c["shrub"], layout, p, true)
	return veg


## Where every plant goes, per chunk: {name, variant, ichu: [Transform3D], shrub: [...]}.
## Pure data (deterministic for the layout), so tests can check it without a renderer:
## headless runs do not keep MultiMesh transforms.
static func placements(layout: SectorLayout) -> Array[Dictionary]:
	var rng := RandomNumberGenerator.new()
	rng.seed = layout.plant_seed
	var steps: PackedVector3Array = layout.terrace_steps()
	var half: Vector2 = layout.size * 0.5
	var chunk: float = layout.plant_chunk
	var out: Array[Dictionary] = []
	for cx: int in ceili(layout.size.x / chunk):
		for cz: int in ceili(layout.size.y / chunk):
			var origin := Vector2(-half.x + cx * chunk, -half.y + cz * chunk)
			var ichu_xf: Array = []
			var shrub_xf: Array = []
			_fill_chunk(layout, steps, rng, origin, chunk, ichu_xf, shrub_xf)
			# One variant per chunk, alternating: neighbours differ, one draw call per kind.
			(
				out
				. append(
					{
						"name": "%d_%d" % [cx, cz],
						"variant": (cx + cz) % VARIANTS,
						"ichu": ichu_xf,
						"shrub": shrub_xf,
					}
				)
			)
	return out


## Candidates in one chunk: Poisson-like by expected count, then filtered.
static func _fill_chunk(
	layout: SectorLayout,
	steps: PackedVector3Array,
	rng: RandomNumberGenerator,
	origin: Vector2,
	chunk: float,
	ichu_xf: Array,
	shrub_xf: Array
) -> void:
	var area: float = chunk * chunk
	var tries: int = (
		int(area * maxf(layout.ichu_side_density, layout.ichu_corridor_density))
		+ int(area * layout.shrub_density)
		+ 1
	)
	for i: int in tries:
		var xz: Vector2 = origin + Vector2(rng.randf() * chunk, rng.randf() * chunk)
		var corridor: float = layout.corridor_half_width(xz.y)
		var outside: float = absf(xz.x) - corridor
		if outside > layout.plant_side_band:
			continue
		var on_side: bool = outside > 0.0
		var roll: float = rng.randf() * maxf(layout.ichu_side_density, layout.ichu_corridor_density)
		var is_shrub: bool = (
			rng.randf() < layout.shrub_density / maxf(layout.ichu_side_density, 0.001)
		)
		var density: float = layout.ichu_side_density if on_side else layout.ichu_corridor_density
		if not is_shrub and roll > density:
			continue
		if not is_clear(layout, steps, xz):
			continue
		var at := Vector3(xz.x, layout.height_at(xz.x, xz.y) - 0.03, xz.y)
		var basis := Basis(Vector3.UP, rng.randf() * TAU).scaled(
			Vector3.ONE * rng.randf_range(0.7, 1.35)
		)
		if is_shrub:
			shrub_xf.append(Transform3D(basis, at - Vector3(0, 0.1, 0)))
		else:
			ichu_xf.append(Transform3D(basis, at))


## True where a plant may grow.
static func is_clear(layout: SectorLayout, steps: PackedVector3Array, xz: Vector2) -> bool:
	if layout.distance_to_path(xz) < layout.path_width * 0.5 + CLEAR_PATH:
		return false
	for s: Vector3 in steps:
		# The retaining wall and the stairs in front of it.
		if xz.y > s.x - 1.2 and xz.y < s.x + 0.4:
			return false
	for h: Vector3 in layout.houses:
		if xz.distance_to(Vector2(h.x, h.y)) < 4.0:
			return false
	for c: Vector3 in layout.corrals:
		if xz.distance_to(Vector2(c.x, c.y)) < c.z + 0.8:
			return false
	if xz.distance_to(layout.huaca) < 3.4 or layout.near_shrine(xz, 3.4):
		return false
	if layout.distance_to_stream(xz) < layout.stream_width * 0.5 + 1.0:
		return false
	for e: Vector3 in layout.encounters:
		if xz.distance_to(Vector2(e.x, e.y)) < e.z + CLEAR_ZONE:
			return false
	return true


static func _multimesh(
	parent: Node3D,
	node_name: String,
	mesh: ArrayMesh,
	transforms: Array,
	layout: SectorLayout,
	p: PaletteTuning,
	shadows: bool
) -> void:
	if transforms.is_empty():
		return
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = mesh
	mm.instance_count = transforms.size()
	for i: int in transforms.size():
		mm.set_instance_transform(i, transforms[i] as Transform3D)
	var node := MultiMeshInstance3D.new()
	node.name = node_name
	node.multimesh = mm
	node.material_override = PaletteMaterials.material_for(p, PaletteMaterials.Role.PLANT)
	node.cast_shadow = (
		GeometryInstance3D.SHADOW_CASTING_SETTING_ON
		if shadows
		else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	)
	# Measured from the chunk's centre: a chunk is up to half its size closer than that.
	node.visibility_range_end = layout.plant_range + layout.plant_chunk * 0.5
	node.visibility_range_end_margin = 8.0
	parent.add_child(node)
