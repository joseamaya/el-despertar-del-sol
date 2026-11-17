class_name SectorBuilder
extends RefCounted
## Builds a hillside sector from a SectorLayout and a PaletteTuning (F3 task 4): faceted
## ground with heightmap collision, pirca terrace walls, stone stairs with ramp collision,
## the path, houses, the huaca, boundary walls and markers for the points of interest.
## Blockout quality: the detailed kit replaces the pieces in task 5.

const WORLD_LAYER: int = 1
## Ground mesh cell (x, z) in metres. Collision always samples every metre.
const MESH_CELL: Vector2 = Vector2(2.0, 1.0)
const STEP_RISE: float = 0.2
const STEP_RUN: float = 0.3
const STAIR_WIDTH: float = 1.8
const RAMP_THICKNESS: float = 0.3


## Builds the sector under a new Node3D named "Sector" (local frame; caller rotates it).
static func build(layout: SectorLayout, palette: PaletteTuning) -> Node3D:
	var root := Node3D.new()
	root.name = "Sector"
	var heights := HeightGrid.new(layout)
	_build_ground(root, layout, palette, heights)
	for step: Vector3 in layout.terrace_steps():
		_build_terrace_wall(root, layout, palette, step)
	_build_stairs(root, layout, palette)
	_build_path(root, layout, palette, heights)
	for w: Vector4 in layout.boundary_walls:
		_build_boundary(root, layout, palette, w)
	var i: int = 0
	for h: Vector3 in layout.houses:
		_build_house(root, layout, palette, h, i)
		i += 1
	_build_huaca(root, layout, palette)
	SectorDressing.dress(root, layout, palette)
	SectorVegetation.plant(root, layout, palette)
	_build_markers(root, layout)
	return root


## Heights of the layout sampled every metre, row by row (fast: one profile lookup per row).
class HeightGrid:
	var width: int
	var depth: int
	var origin: Vector2
	var data: PackedFloat32Array

	func _init(layout: SectorLayout) -> void:
		width = int(layout.size.x) + 1
		depth = int(layout.size.y) + 1
		origin = -layout.size * 0.5
		data.resize(width * depth)
		for iz: int in depth:
			var z: float = origin.y + iz
			var base: float = layout.profile_at(z)
			var half: float = layout.corridor_half_width(z)
			for ix: int in width:
				var outside: float = absf(origin.x + ix) - half
				data[iz * width + ix] = base + maxf(outside, 0.0) * layout.side_grade

	func at(x: float, z: float) -> float:
		var fx: float = clampf(x - origin.x, 0.0, width - 1.0)
		var fz: float = clampf(z - origin.y, 0.0, depth - 1.0)
		var ix: int = mini(int(fx), width - 2)
		var iz: int = mini(int(fz), depth - 2)
		var tx: float = fx - ix
		var tz: float = fz - iz
		var a: float = lerpf(data[iz * width + ix], data[iz * width + ix + 1], tx)
		var b: float = lerpf(data[(iz + 1) * width + ix], data[(iz + 1) * width + ix + 1], tx)
		return lerpf(a, b, tz)


static func _build_ground(
	root: Node3D, layout: SectorLayout, palette: PaletteTuning, heights: HeightGrid
) -> void:
	var cells := Vector2i(int(layout.size.x / MESH_CELL.x), int(layout.size.y / MESH_CELL.y))
	var sample := func(xz: Vector2) -> float: return heights.at(xz.x, xz.y)
	var mesh: ArrayMesh = LowPolyTerrain.ground_grid(
		layout.size, cells, sample, palette.earth, palette.dry_grass, 7
	)
	add_mesh(root, "Ground", mesh, palette, Vector3.ZERO)
	var shape := HeightMapShape3D.new()
	shape.map_width = heights.width
	shape.map_depth = heights.depth
	shape.map_data = heights.data
	var body := static_body(root, "GroundBody")
	var col := CollisionShape3D.new()
	col.shape = shape
	body.add_child(col)


static func _build_terrace_wall(
	root: Node3D, layout: SectorLayout, palette: PaletteTuning, step: Vector3
) -> void:
	var z_low: float = step.x
	var drop: float = step.z - step.y
	var length: float = (layout.corridor_half_width(z_low) + drop / layout.side_grade + 1.0) * 2.0
	var t: float = layout.wall_thickness
	var mesh: ArrayMesh = KitWalls.terrace_wall(length, drop, t, int(z_low * 10.0), palette)
	var centre := Vector3(0.0, step.y, z_low - t * 0.5)
	add_mesh(root, "Terrace_%d" % int(z_low), mesh, palette, centre - Vector3(length * 0.5, 0, 0))
	add_box_collider(root, centre + Vector3(0, drop * 0.5, 0), Vector3(length, drop, t))


## Stone stairs wherever the path crosses a terrace step, on its downhill side, with a
## ramp collider: the player glides up and down instead of dropping step by step.
static func _build_stairs(root: Node3D, layout: SectorLayout, palette: PaletteTuning) -> void:
	for step: Vector3 in layout.terrace_steps():
		var x: float = layout.path_x_at(step.x)
		if is_nan(x):
			continue
		var drop: float = step.z - step.y
		var run: float = ceili(drop / STEP_RISE) * STEP_RUN
		var stairs: ArrayMesh = KitWalls.stairs(
			drop, STAIR_WIDTH, STEP_RISE, STEP_RUN, int(step.x) + 77, palette
		)
		add_mesh(root, "Stairs_%d" % int(step.x), stairs, palette, Vector3(x, step.y, step.x))
		var bottom := Vector3(x, step.y, step.x + run)
		var top_edge := Vector3(x, step.z, step.x)
		var along: Vector3 = top_edge - bottom
		var ramp := CollisionShape3D.new()
		var box := BoxShape3D.new()
		box.size = Vector3(STAIR_WIDTH, RAMP_THICKNESS, along.length())
		ramp.shape = box
		var body := static_body(root, "Ramp_%d" % int(step.x))
		body.add_child(ramp)
		var forward: Vector3 = along.normalized()
		var up: Vector3 = forward.cross(Vector3.RIGHT).normalized()
		if up.y < 0.0:
			up = -up
		body.transform = Transform3D(
			Basis(Vector3.RIGHT, up, -forward),
			(bottom + top_edge) * 0.5 - up * RAMP_THICKNESS * 0.5
		)


static func _build_path(
	root: Node3D, layout: SectorLayout, palette: PaletteTuning, heights: HeightGrid
) -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var colour: Color = palette.earth.darkened(0.12)
	var half: float = layout.path_width * 0.5
	for i: int in range(layout.path.size() - 1):
		var a: Vector2 = layout.path[i]
		var b: Vector2 = layout.path[i + 1]
		var dir: Vector2 = (b - a).normalized()
		var side := Vector2(-dir.y, dir.x) * half
		var pieces: int = maxi(1, int(a.distance_to(b)))
		for k: int in pieces:
			var p0: Vector2 = a.lerp(b, float(k) / pieces)
			var p1: Vector2 = a.lerp(b, float(k + 1) / pieces)
			var q := PackedVector3Array()
			for c: Vector2 in [p0 - side, p1 - side, p1 + side, p0 + side]:
				q.append(Vector3(c.x, heights.at(c.x, c.y) + 0.04, c.y))
			# Skip pieces that fold over a terrace wall: the stairs cover them.
			if absf(q[0].y - q[1].y) > 0.5 or absf(q[3].y - q[2].y) > 0.5:
				continue
			LowPolyMesh.add_quad(st, q[0], q[1], q[2], q[3], colour, Vector3.UP)
	add_mesh(root, "Path", st.commit(), palette, Vector3.ZERO)


static func _build_boundary(
	root: Node3D, layout: SectorLayout, palette: PaletteTuning, w: Vector4
) -> void:
	var a := Vector2(w.x, w.y)
	var b := Vector2(w.z, w.w)
	var length: float = a.distance_to(b)
	var base: float = minf(layout.height_at(a.x, a.y), layout.height_at(b.x, b.y)) - 0.3
	var top: float = maxf(layout.height_at(a.x, a.y), layout.height_at(b.x, b.y))
	var h: float = top - base + layout.boundary_height
	var mesh: ArrayMesh = KitWalls.boundary_wall(length, h, int(w.x * 7.0 + w.y), palette)
	var node := add_mesh(root, "Boundary", mesh, palette, Vector3(a.x, base, a.y))
	var angle: float = atan2(-(b.y - a.y), b.x - a.x)
	node.rotation.y = angle
	var mid := Vector3((a.x + b.x) * 0.5, base + h * 0.5, (a.y + b.y) * 0.5)
	var col := add_box_collider(root, mid, Vector3(length, h, 0.6))
	col.rotation.y = angle


static func _build_house(
	root: Node3D, layout: SectorLayout, palette: PaletteTuning, h: Vector3, index: int
) -> void:
	var size := Vector3(4.5, 2.2, 3.6)
	var house := Node3D.new()
	house.name = "House%d" % index
	house.position = Vector3(h.x, layout.height_at(h.x, h.y), h.y)
	house.rotation.y = deg_to_rad(h.z)
	root.add_child(house)
	add_mesh(house, "Mesh", KitBuildings.house(size, 30 + index, palette), palette, Vector3.ZERO)
	add_box_collider(house, Vector3(0, size.y * 0.5, 0), size)


static func _build_huaca(root: Node3D, layout: SectorLayout, palette: PaletteTuning) -> void:
	var at := Vector3(
		layout.huaca.x, layout.height_at(layout.huaca.x, layout.huaca.y), layout.huaca.y
	)
	add_mesh(root, "HuacaMesh", KitBuildings.huaca(40, palette), palette, at)
	# Low ring of pirca around it: colliders per segment, the opening stays walkable.
	for seg: Array in KitWalls.corral_segments(2.6, 50.0):
		var xf: Transform3D = seg[0]
		var length: float = seg[1]
		var mid: Vector3 = at + xf.origin + xf.basis.x * length * 0.5 + Vector3.UP * 0.3
		var ring := add_box_collider(root, mid, Vector3(length, 0.6, 0.5))
		ring.basis = xf.basis
	var body := static_body(root, "HuacaBody")
	body.position = at + Vector3(0, 1.4, 0)
	var col := CollisionShape3D.new()
	var cyl := CylinderShape3D.new()
	cyl.radius = 1.0
	cyl.height = 2.8
	col.shape = cyl
	body.add_child(col)


static func _build_markers(root: Node3D, layout: SectorLayout) -> void:
	_marker(root, "Start", layout, layout.start, 0.0)
	_marker(root, "Huaca", layout, layout.huaca, 0.0)
	var i: int = 1
	for e: Vector3 in layout.encounters:
		_marker(root, "Encounter%d" % i, layout, Vector2(e.x, e.y), e.z)
		i += 1


static func _marker(
	root: Node3D, marker_name: String, layout: SectorLayout, at: Vector2, radius: float
) -> void:
	var m := Marker3D.new()
	m.name = marker_name
	m.position = Vector3(at.x, layout.height_at(at.x, at.y), at.y)
	m.set_meta(&"radius", radius)
	root.add_child(m)


static func add_mesh(
	parent: Node3D, node_name: String, mesh: ArrayMesh, palette: PaletteTuning, at: Vector3
) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	node.name = node_name
	node.mesh = mesh
	node.material_override = PaletteMaterials.material_for(palette, PaletteMaterials.Role.VERTEX)
	node.position = at
	parent.add_child(node)
	return node


static func static_body(parent: Node3D, body_name: String) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.name = body_name
	body.collision_layer = WORLD_LAYER
	body.collision_mask = 0
	parent.add_child(body)
	return body


static func add_box_collider(parent: Node3D, centre: Vector3, size: Vector3) -> StaticBody3D:
	var body := static_body(parent, "Collider")
	body.position = centre
	var col := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	col.shape = box
	body.add_child(col)
	return body
