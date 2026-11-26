class_name KitCatalog
extends Node3D
## Shows every piece of the modular kit in a row with its name, lit with a palette, for
## review (F3 task 5). Run scenes/tests/kit_catalog.tscn: A/D (or the left stick) move
## along the row, W/S move closer or away, arrows (or the right stick) turn the view.

const SPACING: float = 7.0
const MOVE_SPEED: float = 8.0
const TURN_SPEED: float = 1.6
const START_VIEW := Vector3(0.0, 3.2, 9.0)

@export var palette: PaletteTuning

var camera: Camera3D
var _pieces: Node3D
var _yaw: float = 0.0
var _pitch: float = -0.22


func _ready() -> void:
	assert(palette != null, "KitCatalog needs a palette.")
	rebuild()
	camera = Camera3D.new()
	camera.name = "ReviewCamera"
	camera.position = START_VIEW
	add_child(camera)
	camera.make_current()
	_apply_view()


func _process(delta: float) -> void:
	var move: Vector2 = Input.get_vector(&"move_left", &"move_right", &"move_forward", &"move_back")
	var look: Vector2 = Input.get_vector(&"look_left", &"look_right", &"look_up", &"look_down")
	if move.is_zero_approx() and look.is_zero_approx():
		return
	_yaw -= look.x * TURN_SPEED * delta
	_pitch = clampf(_pitch - look.y * TURN_SPEED * delta, -1.2, 0.6)
	var flat := Basis(Vector3.UP, _yaw)
	camera.position += flat * Vector3(move.x, 0.0, move.y) * MOVE_SPEED * delta
	camera.position.y = maxf(camera.position.y, 0.5)
	_apply_view()


func _apply_view() -> void:
	camera.rotation = Vector3(_pitch, _yaw, 0.0)


func rebuild() -> void:
	if _pieces != null:
		_pieces.free()
	_pieces = Node3D.new()
	_pieces.name = "Pieces"
	add_child(_pieces)
	var env := WorldEnvironment.new()
	env.environment = PaletteMaterials.environment_for(palette)
	_pieces.add_child(env)
	var sun := DirectionalLight3D.new()
	PaletteMaterials.apply_sun(palette, sun)
	_pieces.add_child(sun)
	var flat := func(_xz: Vector2) -> float: return 0.0
	_add(
		"Suelo",
		LowPolyTerrain.ground(Vector2(120, 40), 30, flat, palette.earth, palette.dry_grass, 1),
		Vector3(40, 0, 6)
	)
	var entries: Array[Array] = pieces(palette)
	var i: int = 0
	for entry: Array in entries:
		_add(entry[0], entry[1], Vector3(i * SPACING, 0, 0) + (entry[2] as Vector3))
		i += 1


## Every piece of the kit: [name, mesh, offset]. Shared with the tests.
static func pieces(p: PaletteTuning) -> Array[Array]:
	return [
		["Pirca de terraza", KitWalls.terrace_wall(4.0, 1.6, 1.0, 1, p), Vector3(-2, 0, 0)],
		["Pirca de linde", KitWalls.boundary_wall(4.0, 1.0, 2, p), Vector3(-2, 0, 0)],
		["Cabecera", KitWalls.wall_end(1.6, 1.0, 3, p), Vector3.ZERO],
		["Escalera", KitWalls.stairs(1.6, 1.8, 0.2, 0.3, 4, p), Vector3(0, 0, -1)],
		["Casa", KitBuildings.house(Vector3(4.5, 2.2, 3.6), 5, p), Vector3.ZERO],
		["Techo de ichu", KitBuildings.roof(4.5, 3.6, 6, p), Vector3.ZERO],
		["Corral", KitWalls.corral(2.6, 1.0, 40.0, 7, p), Vector3.ZERO],
		["Huaca", KitBuildings.huaca(8, p), Vector3.ZERO],
		["Huaca de la plaza", KitBuildings.standing_huaca(16, p), Vector3.ZERO],
		["Casa mayor", KitBuildings.house(Vector3(7.0, 2.6, 4.2), 17, p), Vector3.ZERO],
		["Casa cerrada", KitBuildings.house(Vector3(4.5, 2.2, 3.6), 18, p, true), Vector3.ZERO],
		["Rocas", _rocks(p), Vector3.ZERO],
		["Peña", KitBuildings.crag(5.0, 9, p), Vector3.ZERO],
		["Borde de camino", _edge(p), Vector3(-2, 0, 0)],
		["Acequia", KitWalls.channel(4.0, 10, p), Vector3(-2, 0, 0)],
		["Fogón", KitProps.piece(KitProps.Kind.HEARTH, 11, p), Vector3.ZERO],
		["Vasija volcada", KitProps.piece(KitProps.Kind.POT, 12, p), Vector3.ZERO],
		["Bulto", KitProps.piece(KitProps.Kind.BUNDLE, 13, p), Vector3.ZERO],
		["Cesto de maíz", KitProps.piece(KitProps.Kind.BASKET, 14, p), Vector3.ZERO],
		["Piedra de asiento", KitProps.piece(KitProps.Kind.SEAT, 15, p), Vector3.ZERO],
	]


static func _rocks(p: PaletteTuning) -> ArrayMesh:
	return (
		KitWalls
		. merge(
			[
				[KitBuildings.loose_rock(0, 11, p), Transform3D(Basis(), Vector3(-1.6, 0, 0.5))],
				[KitBuildings.loose_rock(1, 12, p), Transform3D(Basis(), Vector3(-0.6, 0, -0.2))],
				[KitBuildings.loose_rock(2, 13, p), Transform3D(Basis(), Vector3(1.2, 0, 0))],
			]
		)
	)


static func _edge(p: PaletteTuning) -> ArrayMesh:
	var parts: Array[Array] = []
	for i: int in 10:
		parts.append([KitWalls.pebble(20 + i, p), Transform3D(Basis(), Vector3(i * 0.42, 0, 0))])
	return KitWalls.merge(parts)


func _add(label: String, mesh: ArrayMesh, at: Vector3) -> void:
	var node := MeshInstance3D.new()
	node.mesh = mesh
	node.material_override = PaletteMaterials.material_for(palette, PaletteMaterials.Role.VERTEX)
	node.position = at
	_pieces.add_child(node)
	if label == "Suelo":
		return
	var text := Label3D.new()
	text.text = label
	text.font_size = 64
	text.pixel_size = 0.004
	text.position = Vector3(at.x, 4.6, 2.5)
	text.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	text.modulate = Color(0.15, 0.12, 0.1)
	text.outline_size = 0
	_pieces.add_child(text)
