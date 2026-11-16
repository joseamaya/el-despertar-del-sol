class_name KitBuildings
extends RefCounted
## Modular kit v1, buildings and landmarks (F3 task 5; docs/guia-visual.md): a one-room
## house (stone footing, adobe walls and gables, rectangular door with a stone lintel,
## layered ichu roof with a tied ridge), the huaca, loose rocks and the crags that frame
## the pass. The house door faces +Z; its ridge runs along X.

const FOOTING: float = 0.6
const WALL: float = 0.4
const DOOR: Vector2 = Vector2(0.9, 1.7)
const ROOF_RISE: float = 1.7
const ROOF_OVERHANG: float = 0.35


## A one-room house of `size` (x width, y wall height, z depth), origin at the centre of
## the floor. Walls, roof and door in one mesh.
static func house(size: Vector3, seed: int, p: PaletteTuning) -> ArrayMesh:
	var parts: Array[Array] = []
	var hx: float = size.x * 0.5
	var hz: float = size.z * 0.5
	# Stone footing: back, sides, and the front in two pieces around the door.
	var back := Transform3D(Basis(), Vector3(-hx, 0, -hz + WALL * 0.5))
	parts.append([_pirca(size.x, seed, p), back])
	for side: float in [-1.0, 1.0]:
		var xf := Transform3D(
			Basis(Vector3.UP, PI * 0.5 * side), Vector3(side * (hx - WALL * 0.5), 0, hz * side)
		)
		parts.append([_pirca(size.z, seed + 1, p), xf])
	var front_len: float = (size.x - DOOR.x) * 0.5
	parts.append(
		[_pirca(front_len, seed + 2, p), Transform3D(Basis(), Vector3(-hx, 0, hz - WALL * 0.5))]
	)
	parts.append(
		[
			_pirca(front_len, seed + 3, p),
			Transform3D(Basis(), Vector3(DOOR.x * 0.5, 0, hz - WALL * 0.5))
		]
	)
	# Adobe walls above the footing, with the door gap continuing up to the lintel.
	var adobe: ArrayMesh = LowPolyMesh.adobe_house_walls(
		Vector3(size.x, size.y - FOOTING, size.z),
		WALL,
		Vector2(DOOR.x, DOOR.y - FOOTING),
		p.adobe,
		seed
	)
	parts.append([adobe, Transform3D(Basis(), Vector3(0, FOOTING, 0))])
	parts.append([_gables(size, p), Transform3D.IDENTITY])
	parts.append([_door_frame(seed, p), Transform3D(Basis(), Vector3(0, 0, hz - WALL * 0.5))])
	parts.append([roof(size.x, size.z, seed, p), Transform3D(Basis(), Vector3(0, size.y, 0))])
	return KitWalls.merge(parts)


## Layered ichu roof over a `width` (x) × `depth` (z) footprint, ridge along X, eaves at
## y = 0. Three stacked layers of thatch and a tied ridge bundle.
static func roof(width: float, depth: float, seed: int, p: PaletteTuning) -> ArrayMesh:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var parts: Array[Array] = []
	var ridge_along_x := Basis(Vector3.UP, PI * 0.5)
	for layer: int in 3:
		# Each layer is shorter at the eaves and sits higher: the steps read as bundles.
		var shrink: float = layer * 0.35
		var tint: Color = p.ichu.lerp(p.ichu.darkened(0.25), rng.randf_range(0.0, 0.6))
		var mesh: ArrayMesh = LowPolyMesh.gable_roof(
			depth - shrink * 2.0,
			width + 0.1 - shrink,
			ROOF_RISE - shrink * 0.9,
			ROOF_OVERHANG,
			tint
		)
		parts.append([mesh, Transform3D(ridge_along_x, Vector3(0, layer * 0.2, 0))])
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var ridge_y: float = ROOF_RISE + 0.12
	var bundle: Color = p.ichu.darkened(0.35)
	LowPolyMesh.add_box(
		st,
		Vector3(0, ridge_y, 0),
		Vector3(width + ROOF_OVERHANG * 2.0 + 0.3, 0.3, 0.34),
		bundle,
		rng,
		0.04
	)
	# Ties around the ridge bundle.
	var ties: int = int(width / 0.9)
	for i: int in ties + 1:
		var x: float = -width * 0.5 + i * width / maxf(ties, 1)
		LowPolyMesh.add_box(
			st, Vector3(x, ridge_y, 0), Vector3(0.08, 0.36, 0.4), bundle.darkened(0.3), rng, 0.0
		)
	parts.append([st.commit(), Transform3D.IDENTITY])
	return KitWalls.merge(parts)


## The huaca of the slice (licence of the game): a standing rock inside a low ring of
## pirca, with small piles of stones and two bowls as offerings. Origin at the rock.
static func huaca(seed: int, p: PaletteTuning) -> ArrayMesh:
	var parts: Array[Array] = []
	parts.append([LowPolyMesh.rock(1.1, 1.35, seed, p.huaca_stone, 0.3), Transform3D.IDENTITY])
	parts.append([KitWalls.corral(2.6, 0.55, 50.0, seed + 5, p), Transform3D.IDENTITY])
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i: int in 3:
		var angle: float = deg_to_rad(-40.0 + i * 40.0)
		var at := Vector3(sin(angle), 0, cos(angle)) * 1.6
		var y: float = 0.0
		for k: int in 3:
			var r: float = 0.12 - k * 0.025
			var tint: Color = p.stone_light.lerp(p.stone_dark, rng.randf())
			var stone: ArrayMesh = LowPolyMesh.rock(r, 0.6, seed + i * 3 + k, tint, 0.25)
			st.append_from(stone, 0, Transform3D(Basis(), at + Vector3(0, y, 0)))
			y += r * 1.1
	for side: float in [-1.0, 1.0]:
		_bowl(st, Vector3(side * 0.7, 0, 1.35), p.adobe.darkened(0.3))
	parts.append([st.commit(), Transform3D.IDENTITY])
	return KitWalls.merge(parts)


## Loose rock for scatter: size 0 small, 1 medium, 2 large.
static func loose_rock(size: int, seed: int, p: PaletteTuning) -> ArrayMesh:
	var radii: Array[float] = [0.25, 0.55, 1.1]
	var tint: Color = p.stone_light.lerp(p.stone_dark, 0.35 + 0.15 * size)
	return LowPolyMesh.rock(radii[clampi(size, 0, 2)], 0.75, seed, tint, 0.3)


## A crag of three rocks, about `height` m tall, to frame the pass.
static func crag(height: float, seed: int, p: PaletteTuning) -> ArrayMesh:
	var r: float = height / 2.7
	var dark: Color = p.stone_dark.lerp(p.huaca_stone, 0.3)
	var parts: Array[Array] = [
		[LowPolyMesh.rock(r, 1.35, seed, dark, 0.28), Transform3D.IDENTITY],
		[
			LowPolyMesh.rock(r * 0.7, 1.1, seed + 1, dark.lightened(0.06), 0.3),
			Transform3D(Basis(), Vector3(r * 0.9, 0, r * 0.3))
		],
		[
			LowPolyMesh.rock(r * 0.55, 0.9, seed + 2, dark.darkened(0.05), 0.3),
			Transform3D(Basis(), Vector3(-r * 0.8, 0, r * 0.5))
		],
	]
	return KitWalls.merge(parts)


static func _pirca(length: float, seed: int, p: PaletteTuning) -> ArrayMesh:
	return LowPolyMesh.pirca_wall(length, FOOTING, WALL + 0.1, seed, p.stone_light, p.stone_dark)


## Adobe triangles closing both ends (x = ±width/2) under the ridge.
static func _gables(size: Vector3, p: PaletteTuning) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var hz: float = size.z * 0.5
	for side: float in [-1.0, 1.0]:
		for face: float in [-1.0, 1.0]:
			var x: float = side * (size.x * 0.5 - WALL * 0.5) + face * WALL * 0.5
			LowPolyMesh.add_tri(
				st,
				Vector3(x, size.y, -hz),
				Vector3(x, size.y, hz),
				Vector3(x, size.y + ROOF_RISE * 0.95, 0),
				p.adobe.darkened(0.04),
				Vector3(face, 0, 0)
			)
	return st.commit()


## Stone jambs and a lintel slab around the door (door centred on x = 0, z = 0).
static func _door_frame(seed: int, p: PaletteTuning) -> ArrayMesh:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for side: float in [-1.0, 1.0]:
		var y: float = 0.0
		while y < DOOR.y - 0.05:
			var h: float = minf(rng.randf_range(0.3, 0.45), DOOR.y - y)
			var tint: Color = p.stone_light.lerp(p.stone_dark, rng.randf())
			LowPolyMesh.add_box(
				st,
				Vector3(side * (DOOR.x * 0.5 + 0.14), y + h * 0.5, 0),
				Vector3(0.28, h - 0.02, WALL + 0.14),
				tint,
				rng,
				0.03
			)
			y += h
	LowPolyMesh.add_box(
		st,
		Vector3(0, DOOR.y + 0.11, 0),
		Vector3(DOOR.x + 0.7, 0.22, WALL + 0.18),
		p.stone_light,
		rng,
		0.02
	)
	return st.commit()


## A small ceramic bowl: an open octagonal cup.
static func _bowl(st: SurfaceTool, at: Vector3, colour: Color) -> void:
	var sides: int = 8
	var r0: float = 0.1
	var r1: float = 0.16
	var h: float = 0.1
	for i: int in sides:
		var a0: float = TAU * i / sides
		var a1: float = TAU * (i + 1) / sides
		var b0 := at + Vector3(cos(a0) * r0, 0, sin(a0) * r0)
		var b1 := at + Vector3(cos(a1) * r0, 0, sin(a1) * r0)
		var t0 := at + Vector3(cos(a0) * r1, h, sin(a0) * r1)
		var t1 := at + Vector3(cos(a1) * r1, h, sin(a1) * r1)
		var out := Vector3(cos((a0 + a1) * 0.5), 0.2, sin((a0 + a1) * 0.5))
		LowPolyMesh.add_quad(st, b0, b1, t1, t0, colour, out)
		LowPolyMesh.add_quad(st, b0, t0, t1, b1, colour.darkened(0.3), -out)
