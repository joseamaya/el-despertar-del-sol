class_name BackdropBuilder
extends RefCounted
## Builds what lies beyond a sector (F3 task 6) from a BackdropLayout: the valley with
## field plots, the town as a few merged meshes, the apus and the smoke columns. All far
## geometry skips fog and shadows; the haze is baked into its colours, so it stays cheap
## and readable on the Mobile renderer.

const SMOKE_SHADER: String = "res://resources/shaders/smoke_column.gdshader"
const HOUSE_SIZE: Vector3 = Vector3(5.0, 2.4, 3.8)
## How far below the sector's ground the backdrop hides under it (m).
const SINK: float = 25.0


## Builds the backdrop under a new Node3D named "Backdrop", in the sector's local frame.
## `eye` is the point the haze is measured from (the lookout).
static func build(
	b: BackdropLayout, layout: SectorLayout, p: PaletteTuning, eye: Vector3
) -> Node3D:
	var root := Node3D.new()
	root.name = "Backdrop"
	_build_valley(root, b, layout, p, eye)
	_build_town(root, b, layout, p, eye)
	_build_apus(root, b, p)
	_build_smoke(root, b, layout, p)
	# The sun in the sector's local frame, for the shading baked into far colours.
	var facing := Basis(Vector3.UP, deg_to_rad(layout.facing_deg))
	var to_sun: Vector3 = facing.inverse() * PaletteMaterials.sun_direction(p)
	for node: Node in root.get_children():
		var mi := node as MeshInstance3D
		if mi != null and mi.mesh is ArrayMesh and not String(node.name).begins_with("Smoke"):
			bake_sun(
				mi.mesh as ArrayMesh, mi.basis.inverse() * to_sun, b.sun_shading, b.far_brightness
			)
	return root


## Bakes a simple sun shading into the vertex colours of a far mesh (drawn unshaded):
## faces towards the sun keep their colour, faces away darken by up to `strength`.
static func bake_sun(
	mesh: ArrayMesh, to_sun: Vector3, strength: float, brightness: float = 1.0
) -> void:
	var arrays: Array = mesh.surface_get_arrays(0)
	var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
	var colours: PackedColorArray = arrays[Mesh.ARRAY_COLOR]
	var light: Vector3 = to_sun.normalized()
	for i: int in colours.size():
		var lit: float = clampf(normals[i].normalized().dot(light) * 0.5 + 0.5, 0.0, 1.0)
		var c: Color = colours[i].darkened(strength * (1.0 - lit))
		colours[i] = Color(c.r * brightness, c.g * brightness, c.b * brightness, c.a)
	arrays[Mesh.ARRAY_COLOR] = colours
	mesh.clear_surfaces()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)


## Ground height of the backdrop: under the sector it hides below the sector's ground;
## below the sector it slides from the sector's edge down to the valley.
static func height_at(b: BackdropLayout, layout: SectorLayout, x: float, z: float) -> float:
	var half: Vector2 = layout.size * 0.5
	# Under the sector: well below its ground, so the coarse cells never poke through.
	if absf(x) <= half.x and absf(z) < b.slope_start_z and z > -half.y:
		return layout.height_at(x, z) - SINK
	if z >= b.slope_start_z:
		var t: float = smoothstep(b.slope_start_z, b.slope_end_z, z)
		var edge: float = layout.height_at(clampf(x, -half.x, half.x), b.slope_start_z)
		return lerpf(edge, b.valley_at(x, z), t)
	return maxf(
		b.valley_at(x, z),
		layout.height_at(clampf(x, -half.x, half.x), clampf(z, -half.y, half.y)) - SINK
	)


## Colour after the haze between `eye` and `at`.
static func hazed(
	b: BackdropLayout, p: PaletteTuning, colour: Color, eye: Vector3, at: Vector3
) -> Color:
	var t: float = 1.0 - exp(-eye.distance_to(at) * b.haze)
	return colour.lerp(p.fog_color, t)


static func _build_valley(
	root: Node3D, b: BackdropLayout, layout: SectorLayout, p: PaletteTuning, eye: Vector3
) -> void:
	var cells := Vector2i(int(b.size.x / b.cell), int(b.size.y / b.cell))
	# Align a row of vertices with the sector's lower edge so the two grounds meet there.
	var rows_up: float = ceilf((b.slope_start_z + layout.size.y * 0.5) / b.cell)
	var centre := Vector2(0.0, b.slope_start_z - rows_up * b.cell + b.size.y * 0.5)
	var heights := func(xz: Vector2) -> float:
		return height_at(b, layout, xz.x + centre.x, xz.y + centre.y)
	var colours := func(xz: Vector2, tint: Color) -> Color:
		var world := Vector2(xz.x + centre.x, xz.y + centre.y)
		var base: Color = _plot_colour(b, p, world, tint)
		var at := Vector3(world.x, height_at(b, layout, world.x, world.y), world.y)
		return hazed(b, p, base, eye, at)
	var mesh: ArrayMesh = LowPolyTerrain.ground_grid(
		b.size, cells, heights, p.earth, p.dry_grass, b.seed, colours
	)
	var node := _far_mesh(root, "Valley", mesh, p)
	node.position = Vector3(centre.x, 0, centre.y)


## Fields on the valley floor (plots of green and ochre), dry slopes on the hills.
static func _plot_colour(
	b: BackdropLayout, p: PaletteTuning, world: Vector2, slope_tint: Color
) -> Color:
	var r: float = world.distance_to(b.town_centre)
	if r > b.hills_start or world.y < b.slope_end_z:
		return slope_tint
	if r < b.town_radius * 0.9:
		return p.earth.lerp(p.dry_grass, 0.3)
	var cell := Vector2i(floori(world.x / b.plot), floori(world.y / b.plot))
	var h: float = absf(sin(cell.x * 12.9898 + cell.y * 78.233 + b.seed) * 43758.5453)
	h -= floorf(h)
	return p.field_green.lerp(p.field_ochre, h)


## The town: houses grouped in neighbourhoods, one merged mesh per neighbourhood.
static func _build_town(
	root: Node3D, b: BackdropLayout, layout: SectorLayout, p: PaletteTuning, eye: Vector3
) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = b.seed
	var per: int = maxi(1, b.houses / b.neighbourhoods)
	var house: ArrayMesh = _house_impostor(p)
	for n: int in b.neighbourhoods:
		var angle: float = TAU * n / b.neighbourhoods + rng.randf_range(-0.3, 0.3)
		var dist: float = rng.randf_range(0.15, 0.75) * b.town_radius if n > 0 else 0.0
		var centre: Vector2 = b.town_centre + Vector2(cos(angle), sin(angle)) * dist
		var street: float = rng.randf() * PI
		var st := SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		for i: int in per:
			# Houses in rows along a street direction, with gaps: a modest town, not a grid.
			var row: int = i % 8
			var col: int = i / 8
			var local := (
				Vector2(row * 9.0 - 32.0, col * 12.0 - 24.0)
				+ Vector2(rng.randf_range(-2, 2), rng.randf_range(-2, 2))
			)
			var xz: Vector2 = centre + local.rotated(street)
			var at := Vector3(xz.x, height_at(b, layout, xz.x, xz.y), xz.y)
			var basis := Basis(Vector3.UP, -street + (PI * 0.5 if rng.randf() < 0.3 else 0.0))
			st.append_from(house, 0, Transform3D(basis, at))
		var mesh: ArrayMesh = st.commit()
		_tint_by_distance(mesh, b, p, eye)
		_far_mesh(root, "Town%d" % n, mesh, p)


## A tiny house seen from afar: adobe box and an ichu roof, about 20 triangles.
static func _house_impostor(p: PaletteTuning) -> ArrayMesh:
	var st := LowPolyMesh.begin()
	var rng := RandomNumberGenerator.new()
	LowPolyMesh.add_box(st, Vector3(0, HOUSE_SIZE.y * 0.5, 0), HOUSE_SIZE, p.adobe, rng, 0.0)
	var hx: float = HOUSE_SIZE.x * 0.5 + 0.3
	var hz: float = HOUSE_SIZE.z * 0.5 + 0.3
	var y: float = HOUSE_SIZE.y
	var ridge: float = y + 1.6
	for sgn: float in [-1.0, 1.0]:
		LowPolyMesh.add_quad(
			st,
			Vector3(-hx, y, sgn * hz),
			Vector3(hx, y, sgn * hz),
			Vector3(hx, ridge, 0),
			Vector3(-hx, ridge, 0),
			p.ichu,
			Vector3(0, 0.6, sgn)
		)
		LowPolyMesh.add_tri(
			st,
			Vector3(sgn * hx, y, -hz),
			Vector3(sgn * hx, y, hz),
			Vector3(sgn * hx, ridge, 0),
			p.adobe,
			Vector3(sgn, 0, 0)
		)
	return LowPolyMesh.end(st)


## Rewrites the vertex colours of a merged mesh with the haze for its distance.
static func _tint_by_distance(
	mesh: ArrayMesh, b: BackdropLayout, p: PaletteTuning, eye: Vector3
) -> void:
	var arrays: Array = mesh.surface_get_arrays(0)
	var verts: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	var colours: PackedColorArray = arrays[Mesh.ARRAY_COLOR]
	for i: int in verts.size():
		colours[i] = hazed(b, p, colours[i], eye, verts[i])
	arrays[Mesh.ARRAY_COLOR] = colours
	mesh.clear_surfaces()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)


static func _build_apus(root: Node3D, b: BackdropLayout, p: PaletteTuning) -> void:
	var i: int = 0
	for a: Vector4 in b.apus:
		var dir := Vector3(sin(deg_to_rad(a.x)), 0, -cos(deg_to_rad(a.x)))
		var at: Vector3 = dir * a.y + Vector3(0, b.floor_height + b.hills_max * 0.5, 0)
		# The palette's mountain colour already carries the atmosphere: no extra haze.
		var colour: Color = p.mountain
		var node := _far_mesh(root, "Apu%d" % i, LowPolyTerrain.mountain(b.seed + i, colour), p)
		node.position = at
		node.scale = Vector3(a.z, a.w, a.z)
		i += 1


static func _build_smoke(
	root: Node3D, b: BackdropLayout, layout: SectorLayout, p: PaletteTuning
) -> void:
	var shader := load(SMOKE_SHADER) as Shader
	var i: int = 0
	for s: Vector3 in b.smoke:
		var tube := CylinderMesh.new()
		tube.top_radius = s.z * 0.1
		tube.bottom_radius = s.z * 0.045
		tube.height = s.z
		tube.radial_segments = 10
		tube.rings = 1
		tube.cap_top = false
		tube.cap_bottom = false
		var mat := ShaderMaterial.new()
		mat.shader = shader
		mat.set_shader_parameter(&"smoke_color", p.smoke)
		mat.set_shader_parameter(&"seed", float(i) * 3.7)
		mat.set_shader_parameter(&"column_height", s.z)
		var node := MeshInstance3D.new()
		node.name = "Smoke%d" % i
		node.mesh = tube
		node.material_override = mat
		node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		node.position = Vector3(s.x, height_at(b, layout, s.x, s.y) + s.z * 0.5, s.y)
		root.add_child(node)
		i += 1


static func _far_mesh(
	root: Node3D, node_name: String, mesh: ArrayMesh, p: PaletteTuning
) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	node.name = node_name
	node.mesh = mesh
	node.material_override = PaletteMaterials.material_for(p, PaletteMaterials.Role.FAR)
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.add_child(node)
	return node
