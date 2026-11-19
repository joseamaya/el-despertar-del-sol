class_name KitProps
extends RefCounted
## Traces of a neighbourhood left in a hurry (F4 task 12c): a hearth of three stones
## still glowing, a tipped jar with a broken shard, a bundle tied in a manta, a spilled
## basket of maize and a flat stone to sit on. Low-poly and vertex-coloured like the rest
## of the kit; origin on the ground, front towards +Z.

enum Kind { HEARTH, POT, BUNDLE, BASKET, SEAT }


static func piece(kind: Kind, seed: int, p: PaletteTuning) -> ArrayMesh:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var st := LowPolyMesh.begin()
	match kind:
		Kind.HEARTH:
			_hearth(st, rng, p)
		Kind.POT:
			_pot(st, rng, p)
		Kind.BUNDLE:
			_bundle(st, rng, p)
		Kind.BASKET:
			_basket(st, rng, p)
		Kind.SEAT:
			var stone: ArrayMesh = LowPolyMesh.rock(0.32, 0.6, seed, p.stone_light, 0.15)
			st.append_from(stone, 0, Transform3D.IDENTITY)
	return LowPolyMesh.end(st)


## Three stones around a bed of ash with a few embers.
static func _hearth(st: SurfaceTool, rng: RandomNumberGenerator, p: PaletteTuning) -> void:
	var ash: Color = p.stone_dark.darkened(0.45)
	LowPolyMesh.add_box(st, Vector3(0, 0.02, 0), Vector3(0.7, 0.04, 0.7), ash, rng, 0.05)
	for i: int in 3:
		var a: float = TAU * i / 3.0
		var tint: Color = p.stone_dark.lerp(p.stone_light, rng.randf() * 0.5)
		var stone: ArrayMesh = LowPolyMesh.rock(0.16, 0.9, rng.randi(), tint, 0.25)
		st.append_from(stone, 0, Transform3D(Basis(), Vector3(cos(a), 0, sin(a)) * 0.34))
	var ember: Color = p.inca_red.lerp(p.inca_yellow, 0.35)
	for i: int in 4:
		var at := Vector3(rng.randf_range(-0.15, 0.15), 0.05, rng.randf_range(-0.15, 0.15))
		var size := Vector3(0.1, 0.05, 0.06)
		LowPolyMesh.add_box(st, at, size, ember if i % 2 == 0 else ash.lightened(0.2), rng, 0.02)


## A jar on its side (an eight-sided body narrowing to a neck) and a shard by it.
static func _pot(st: SurfaceTool, rng: RandomNumberGenerator, p: PaletteTuning) -> void:
	var clay: Color = p.adobe.darkened(0.2)
	# Rings along the jar's axis (local +Y before tipping): (height, radius).
	var rings: Array[Vector2] = [
		Vector2(0.0, 0.1), Vector2(0.12, 0.2), Vector2(0.3, 0.17), Vector2(0.4, 0.08)
	]
	var tip := Transform3D(Basis(Vector3.FORWARD, deg_to_rad(80.0)), Vector3(0.2, 0.19, 0))
	_lathe(st, rings, tip, clay)
	var shard := Vector3(-0.25, 0.02, 0.3)
	LowPolyMesh.add_box(st, shard, Vector3(0.14, 0.03, 0.1), clay.darkened(0.15), rng, 0.03)


## A bundle wrapped in a striped manta and tied across.
static func _bundle(st: SurfaceTool, rng: RandomNumberGenerator, p: PaletteTuning) -> void:
	var cloth: Color = p.inca_red.darkened(0.25).lerp(p.earth, 0.35)
	LowPolyMesh.add_box(st, Vector3(0, 0.17, 0), Vector3(0.62, 0.34, 0.44), cloth, rng, 0.05)
	var stripe: Color = p.inca_yellow.darkened(0.2)
	LowPolyMesh.add_box(st, Vector3(0, 0.17, 0), Vector3(0.64, 0.08, 0.46), stripe, rng, 0.01)
	var tie: Color = p.earth.darkened(0.3)
	LowPolyMesh.add_box(st, Vector3(0, 0.36, 0), Vector3(0.12, 0.08, 0.2), tie, rng, 0.02)


## A basket on its side with maize spilling out of its mouth (+Z).
static func _basket(st: SurfaceTool, rng: RandomNumberGenerator, p: PaletteTuning) -> void:
	var weave: Color = p.ichu.darkened(0.25)
	var rings: Array[Vector2] = [Vector2(0.0, 0.16), Vector2(0.3, 0.24)]
	var tip := Transform3D(Basis(Vector3.RIGHT, deg_to_rad(80.0)), Vector3(0, 0.2, -0.1))
	_lathe(st, rings, tip, weave)
	for i: int in 7:
		var at := Vector3(rng.randf_range(-0.2, 0.2), 0.03, rng.randf_range(0.25, 0.6))
		LowPolyMesh.add_box(st, at, Vector3(0.05, 0.05, 0.12), p.inca_yellow, rng, 0.01)


## An eight-sided open shell through `rings` (height, radius), placed by `xf`.
static func _lathe(st: SurfaceTool, rings: Array[Vector2], xf: Transform3D, colour: Color) -> void:
	var sides: int = 8
	for r: int in rings.size() - 1:
		for i: int in sides:
			var a0: float = TAU * i / sides
			var a1: float = TAU * (i + 1) / sides
			var lo: Vector2 = rings[r]
			var hi: Vector2 = rings[r + 1]
			var b0: Vector3 = xf * Vector3(cos(a0) * lo.y, lo.x, sin(a0) * lo.y)
			var b1: Vector3 = xf * Vector3(cos(a1) * lo.y, lo.x, sin(a1) * lo.y)
			var t0: Vector3 = xf * Vector3(cos(a0) * hi.y, hi.x, sin(a0) * hi.y)
			var t1: Vector3 = xf * Vector3(cos(a1) * hi.y, hi.x, sin(a1) * hi.y)
			var mid_a: float = (a0 + a1) * 0.5
			var out: Vector3 = xf.basis * Vector3(cos(mid_a), 0, sin(mid_a))
			LowPolyMesh.add_quad(st, b0, b1, t1, t0, colour, out)
			LowPolyMesh.add_quad(st, b0, t0, t1, b1, colour.darkened(0.35), -out)
