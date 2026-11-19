class_name SectorLevel
extends Node3D
## A playable hillside sector (F3 task 4): builds the sector from its layout and palette
## when it enters the tree, adds sky, fog and sun, and puts the player at the start
## looking out over the valley.

## Camera pitch at the start, looking down into the valley (radians).
const START_PITCH: float = -0.22

@export var layout: SectorLayout
@export var palette: PaletteTuning
## What lies beyond the sector: valley, town, apus, smoke. Optional.
@export var backdrop: BackdropLayout
@export var player: PlayerController
@export var camera_rig: CameraController
## Optional combat loop (F3 task 9): it gets the start and the spawn markers of the
## encounter zones, so the same ArenaController of F2 runs the fights here.
@export var arena: ArenaController

var sector: Node3D
var navigation: NavigationRegion3D
## Sky, fog and ambient of the sector, built from the palette (visions change the fog).
var environment: Environment


func _ready() -> void:
	assert(layout != null and palette != null, "SectorLevel needs a layout and a palette.")
	rebuild()


## Builds (or rebuilds) the sector and places the player at the start.
func rebuild() -> void:
	if sector != null:
		sector.free()
	sector = SectorBuilder.build(layout, palette)
	sector.rotation.y = deg_to_rad(layout.facing_deg)
	add_child(sector)
	navigation = SectorNavigation.bake(sector, layout)
	if arena != null:
		arena.player_spawn = sector.get_node(^"Start") as Node3D
		arena.spawn_points = spawn_markers()
		# One zone per encounter, started by the slice (F4 task 2).
		arena.zone_sizes = layout.encounter_enemies
		# And the warriors who come when a zone's first ones fall (F4 task 12b).
		arena.wave_points = spawn_markers("Wave")
		arena.wave_sizes = wave_sizes()
	if backdrop != null:
		var eye := Vector3(
			layout.start.x, layout.height_at(layout.start.x, layout.start.y) + 1.6, layout.start.y
		)
		sector.add_child(BackdropBuilder.build(backdrop, layout, palette, eye))
		if player != null and player.camera != null:
			player.camera.far = backdrop.view_distance
	_build_light()
	if player != null:
		# Deferred: the player and the camera rig are siblings that may not be ready yet.
		# The opening shot: the valley of Cusco below (GDD §14.1).
		place_player_at.call_deferred(&"Start", Vector3(0, 0, 1), START_PITCH)


## The spawn markers of every encounter zone, in order ("Wave": the reinforcements').
func spawn_markers(prefix: String = "Spawn") -> Array[Node3D]:
	var out: Array[Node3D] = []
	for node: Node in sector.get_children():
		if String(node.name).begins_with(prefix):
			out.append(node as Node3D)
	return out


## Reinforcements of each encounter zone, in order (0 where none come).
func wave_sizes() -> PackedInt32Array:
	var out := PackedInt32Array()
	for i: int in layout.encounters.size():
		var wave: int = (
			int(layout.encounter_reinforcements[i].z)
			if i < layout.encounter_reinforcements.size()
			else 0
		)
		out.append(wave)
	return out


## Global position of a marker built from the layout (Start, Huaca, Encounter1…).
func marker_position(marker: StringName) -> Vector3:
	return marker_node(marker).global_position


## A marker built from the layout: Start, Huaca, Family, Ending, EncounterN, CheckpointN.
func marker_node(marker: StringName) -> Marker3D:
	return sector.get_node(NodePath(marker)) as Marker3D


## Converts a point of the layout (x, z) to a global position on the ground.
func to_global_point(xz: Vector2) -> Vector3:
	return sector.to_global(Vector3(xz.x, layout.height_at(xz.x, xz.y), xz.y))


## Puts the player on a marker, facing `local_direction` (layout frame; +Z is downhill),
## with the camera pitched by `pitch` radians (negative looks down).
func place_player_at(marker: StringName, local_direction: Vector3, pitch: float = 0.0) -> void:
	var facing: Vector3 = sector.global_basis * local_direction
	var yaw: float = atan2(-facing.x, -facing.z)
	player.respawn(marker_position(marker) + Vector3.UP * 0.1, yaw)
	if camera_rig != null:
		camera_rig.yaw = yaw
		if not is_zero_approx(pitch):
			camera_rig.pitch = pitch
		camera_rig.snap_to_target()


func _build_light() -> void:
	for old: Node in find_children("*", "WorldEnvironment", false, false):
		old.free()
	for old: Node in find_children("*", "DirectionalLight3D", false, false):
		old.free()
	var env := WorldEnvironment.new()
	env.name = "WorldEnvironment"
	environment = PaletteMaterials.environment_for(palette)
	env.environment = environment
	add_child(env)
	var sun := DirectionalLight3D.new()
	sun.name = "Sun"
	PaletteMaterials.apply_sun(palette, sun)
	# In world space, not in the rotated sector: the palette azimuth is a real compass
	# direction (60° = from the east-south-east, a dawn sun).
	add_child(sun)
	var fill: DirectionalLight3D = PaletteMaterials.fill_light(palette)
	if fill != null:
		add_child(fill)
