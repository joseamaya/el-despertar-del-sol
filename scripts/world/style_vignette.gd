class_name StyleVignette
extends Node3D
## Style test for the F3 visual guide: a slice of Carmenca hillside (two pirca terraces
## with stairs, an adobe house with ichu roof, the huaca rock, two figures for scale,
## the valley and the apus) built by code from a PaletteTuning. Provisional geometry:
## the real kit comes in F3 task 5. Two framed shots: WIDE and DETAIL.

enum Shot { WIDE, DETAIL }

const CHARACTER_SCENE: String = "res://assets/characters/stock/ual1_standard.glb"
const TERRACE_DROP: float = 1.6
const WALL_LENGTH: float = 40.0
const WALL_THICKNESS: float = 0.6
const VALLEY_Y: float = -40.0

@export var palette: PaletteTuning

var _built: Node3D
var _sun: DirectionalLight3D
var _world_env: WorldEnvironment
var _cameras: Dictionary = {}


func _ready() -> void:
	assert(palette != null, "StyleVignette needs a palette.")
	rebuild()


## Rebuilds everything from `palette` (call after swapping it).
func rebuild() -> void:
	if _built != null:
		_built.free()
	_built = Node3D.new()
	_built.name = "Built"
	add_child(_built)
	_cameras.clear()
	_build_light()
	_build_ground()
	_build_terraces()
	_build_house(Vector3(-9.0, 0.0, 4.5))
	_build_huaca(Vector3(5.0, -TERRACE_DROP, -3.2))
	_build_mountains()
	_build_figures()
	_build_cameras()
	use_shot(Shot.WIDE)


func use_shot(shot: Shot) -> void:
	(_cameras[shot] as Camera3D).make_current()


func get_camera(shot: Shot) -> Camera3D:
	return _cameras[shot] as Camera3D


## Number of generated scenery meshes (for tests).
func count_meshes() -> int:
	return _built.find_children("*", "MeshInstance3D", true, false).size()


func _build_light() -> void:
	_world_env = WorldEnvironment.new()
	_world_env.environment = PaletteMaterials.environment_for(palette)
	_built.add_child(_world_env)
	_sun = DirectionalLight3D.new()
	_sun.name = "Sun"
	PaletteMaterials.apply_sun(palette, _sun)
	_built.add_child(_sun)


func _build_ground() -> void:
	var low: Color = palette.earth
	var high: Color = palette.dry_grass
	# Uphill, behind the upper terrace: rises gently.
	var upper := func(xz: Vector2) -> float: return maxf(0.0, (xz.y + 15.0 - 4.0) * 0.18)
	_add_mesh(LowPolyMesh.ground(Vector2(60, 30), 20, upper, low, high, 1), Vector3(0, 0, 15))
	# Lower terrace top: flat, mostly earth.
	var flat := func(_xz: Vector2) -> float: return 0.0
	_add_mesh(
		LowPolyMesh.ground(Vector2(WALL_LENGTH, 6), 12, flat, low, low.lerp(high, 0.4), 2),
		Vector3(0, -TERRACE_DROP, -3)
	)
	# Below the lower terrace the hillside falls towards the valley.
	var slope := func(xz: Vector2) -> float:
		var below: float = -(xz.y - 40.0)
		return -below * 0.45 + sin(xz.x * 0.3) * 0.6
	_add_mesh(
		LowPolyMesh.ground(Vector2(90, 80), 24, slope, low, high, 3),
		Vector3(0, -TERRACE_DROP * 2.0, -46)
	)
	var floor_fn := func(_xz: Vector2) -> float: return 0.0
	_add_mesh(
		LowPolyMesh.ground(Vector2(6000, 3000), 16, floor_fn, high, high.lerp(low, 0.5), 4),
		Vector3(0, VALLEY_Y, -1580)
	)


func _build_terraces() -> void:
	for i: int in 2:
		var wall: ArrayMesh = LowPolyMesh.pirca_wall(
			WALL_LENGTH,
			TERRACE_DROP,
			WALL_THICKNESS,
			10 + i,
			palette.stone_light,
			palette.stone_dark
		)
		var base_y: float = -TERRACE_DROP * (i + 1)
		_add_mesh(wall, Vector3(-WALL_LENGTH * 0.5, base_y, -6.0 * i - WALL_THICKNESS * 0.5))
	# Stone stairs in front of the upper wall, down to the lower terrace.
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var rng := RandomNumberGenerator.new()
	rng.seed = 20
	var steps: int = 8
	var rise: float = TERRACE_DROP / steps
	for s: int in steps:
		var top: float = -TERRACE_DROP + rise * (s + 1)
		var z: float = -WALL_THICKNESS - 0.32 * (steps - s)
		var height: float = top + TERRACE_DROP
		var tint: Color = palette.stone_light.lerp(palette.stone_dark, rng.randf())
		LowPolyMesh.add_box(
			st,
			Vector3(6.0, -TERRACE_DROP + height * 0.5, z + 0.16),
			Vector3(1.3, height, 0.34),
			tint,
			rng,
			0.03
		)
	_add_mesh(st.commit(), Vector3.ZERO)


func _build_house(at: Vector3) -> void:
	var house := Node3D.new()
	house.name = "House"
	house.position = at
	house.rotation.y = PI  # door towards the terrace edge
	_built.add_child(house)
	var size := Vector3(4.5, 2.2, 3.6)
	var walls: ArrayMesh = LowPolyMesh.adobe_house_walls(
		size, 0.4, Vector2(0.9, 1.7), palette.adobe, 30
	)
	_add_mesh(walls, Vector3.ZERO, house)
	var roof: ArrayMesh = LowPolyMesh.gable_roof(size.z, size.x, 1.7, 0.45, palette.ichu)
	var roof_node: MeshInstance3D = _add_mesh(roof, Vector3(0, size.y, 0), house)
	roof_node.rotation.y = PI * 0.5  # ridge along the long side


func _build_huaca(at: Vector3) -> void:
	_add_mesh(LowPolyMesh.rock(1.1, 1.35, 40, palette.huaca_stone, 0.3), at)
	# Low pirca ring around it.
	var segments: int = 8
	var ring_radius: float = 2.2
	for i: int in segments:
		var angle: float = TAU * i / segments
		var wall: ArrayMesh = LowPolyMesh.pirca_wall(
			1.6, 0.5, 0.4, 41 + i, palette.stone_light, palette.stone_dark
		)
		var node: MeshInstance3D = _add_mesh(
			wall, at + Vector3(cos(angle), 0, sin(angle)) * ring_radius
		)
		node.rotation.y = -angle + PI * 0.5
		node.position -= node.basis.x * 0.8


func _build_mountains() -> void:
	var peaks: Array[Vector4] = [
		Vector4(-900, -2000, 650, 300),
		Vector4(-150, -2500, 900, 420),
		Vector4(650, -2150, 700, 340),
		Vector4(1500, -1800, 600, 260),
		Vector4(-1700, -1700, 550, 240),
	]
	var i: int = 0
	for p: Vector4 in peaks:
		var node: MeshInstance3D = _add_mesh(
			LowPolyMesh.mountain(50 + i, palette.mountain), Vector3(p.x, VALLEY_Y, p.y)
		)
		node.scale = Vector3(p.z, p.w, p.z)
		node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		# The apus carry their atmospheric tint in their colour: fog would wash them out.
		node.material_override = PaletteMaterials.material_for(palette, PaletteMaterials.Role.FAR)
		i += 1


func _build_figures() -> void:
	_add_figure(Vector3(1.2, 0, 3.0), PI * 0.9, PaletteMaterials.Role.INCA)
	_add_figure(Vector3(3.4, 0, 6.0), PI * 1.1, PaletteMaterials.Role.CHANCA)


func _add_figure(at: Vector3, yaw: float, role: PaletteMaterials.Role) -> void:
	var figure := (load(CHARACTER_SCENE) as PackedScene).instantiate() as Node3D
	figure.position = at
	figure.rotation.y = yaw
	_built.add_child(figure)
	var mat: StandardMaterial3D = PaletteMaterials.material_for(palette, role)
	for mesh: Node in figure.find_children("*", "MeshInstance3D", true, false):
		(mesh as MeshInstance3D).material_override = mat
	for node: Node in figure.find_children("*", "AnimationPlayer", true, false):
		var player := node as AnimationPlayer
		for anim: StringName in player.get_animation_list():
			if String(anim).begins_with("Idle"):
				player.play(anim)
				break


func _build_cameras() -> void:
	_cameras[Shot.WIDE] = _add_camera(
		"ShotWide", Vector3(-1.0, 7.0, 15.0), Vector3(2.0, -9.0, -50.0)
	)
	_cameras[Shot.DETAIL] = _add_camera(
		"ShotDetail", Vector3(-1.5, -0.1, -4.8), Vector3(-7.5, 0.6, 3.5)
	)


func _add_camera(cam_name: String, from: Vector3, target: Vector3) -> Camera3D:
	var cam := Camera3D.new()
	cam.name = cam_name
	cam.fov = 60.0
	cam.far = 5000.0
	_built.add_child(cam)
	cam.look_at_from_position(from, target)
	return cam


func _add_mesh(mesh: ArrayMesh, at: Vector3, parent: Node3D = null) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	node.mesh = mesh
	node.material_override = PaletteMaterials.material_for(palette, PaletteMaterials.Role.VERTEX)
	node.position = at
	(parent if parent != null else _built).add_child(node)
	return node
