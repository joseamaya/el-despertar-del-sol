class_name HuacaRite
extends Node
## An offering at a huaca and its brief vision (F4 task 4, GDD §8.4, §14.1): Cusi leaves
## the offering, gains a little stamina for good, and for a few seconds the fog rises and
## stone figures stand on the terraces below, then fade (a foreshadowing of the
## Pururaucas, never explained, GDD §3.3). The figures exist only during the vision.

signal offering_made(marker: StringName)
signal rite_finished

@export var tuning: HuacaRiteTuning
@export var level: SectorLevel
@export var player: PlayerController
@export var animator: CharacterAnimator
@export var stamina: StaminaComponent
@export var camera_rig: CameraController
## Nodes that read combat input, paused while the rite plays.
@export var frozen: Array[Node] = []

var _figures: Node3D
var _playing: bool = false


func _ready() -> void:
	assert(tuning != null and level != null and player != null, "HuacaRite: parts.")


func is_playing() -> bool:
	return _playing


func perform(marker: StringName) -> void:
	assert(not _playing, "HuacaRite: already playing.")
	_playing = true
	PlayerHold.set_held(player, frozen, true)
	if animator != null:
		animator.play_oneshot_timed(tuning.offering_clip, tuning.offering_time)
	if stamina != null:
		stamina.add_bonus(tuning.stamina_bonus)
	offering_made.emit(marker)
	await get_tree().create_timer(tuning.offering_time, false).timeout
	await _vision(marker)
	PlayerHold.set_held(player, frozen, false)
	_playing = false
	rite_finished.emit()


## The figures' places on the layout (x, z): an arc downhill of the huaca. Pure.
static func figure_places(layout: SectorLayout, t: HuacaRiteTuning) -> PackedVector2Array:
	var rng := RandomNumberGenerator.new()
	rng.seed = t.seed
	var out := PackedVector2Array()
	for i: int in t.figures:
		var share: float = 0.5 if t.figures == 1 else float(i) / (t.figures - 1)
		var angle: float = deg_to_rad(lerpf(-t.arc_deg, t.arc_deg, share) * 0.5)
		var dist: float = rng.randf_range(t.distance_min, t.distance_max)
		# Downhill is +Z in the layout frame.
		out.append(layout.huaca + Vector2(sin(angle), cos(angle)) * dist)
	return out


func _vision(marker: StringName) -> void:
	var env: Environment = level.environment
	var camera: Camera3D = player.camera
	var rest_density: float = env.fog_density
	var rest_color: Color = env.fog_light_color
	var rest_sky: float = env.fog_sky_affect
	var rest_far: float = camera.far if camera != null else 0.0
	_raise_figures()
	_face_figures(marker)
	var up := create_tween().set_parallel()
	up.tween_property(env, ^"fog_density", tuning.fog_density, tuning.fade_in)
	up.tween_property(env, ^"fog_light_color", tuning.fog_color, tuning.fade_in)
	up.tween_property(env, ^"fog_sky_affect", 1.0, tuning.fade_in)
	if camera != null:
		up.tween_property(camera, ^"far", tuning.view_distance, tuning.fade_in).set_ease(
			Tween.EASE_OUT
		)
	for figure: Node in _figures.get_children():
		var mat: StandardMaterial3D = (figure as MeshInstance3D).material_override
		up.tween_property(mat, ^"albedo_color:a", 1.0, tuning.fade_in)
	await up.finished
	await get_tree().create_timer(tuning.hold, false).timeout
	var down := create_tween().set_parallel()
	down.tween_property(env, ^"fog_density", rest_density, tuning.fade_out)
	down.tween_property(env, ^"fog_light_color", rest_color, tuning.fade_out)
	down.tween_property(env, ^"fog_sky_affect", rest_sky, tuning.fade_out)
	if camera != null:
		down.tween_property(camera, ^"far", rest_far, tuning.fade_out).set_ease(Tween.EASE_IN)
	for figure: Node in _figures.get_children():
		var mat: StandardMaterial3D = (figure as MeshInstance3D).material_override
		down.tween_property(mat, ^"albedo_color:a", 0.0, tuning.fade_out)
	await down.finished
	env.fog_density = rest_density
	env.fog_light_color = rest_color
	env.fog_sky_affect = rest_sky
	if camera != null:
		camera.far = rest_far
	_figures.queue_free()
	_figures = null


func _raise_figures() -> void:
	_figures = Node3D.new()
	_figures.name = "VisionFigures"
	level.sector.add_child(_figures)
	var layout: SectorLayout = level.layout
	var places: PackedVector2Array = figure_places(layout, tuning)
	for i: int in places.size():
		var xz: Vector2 = places[i]
		var figure := MeshInstance3D.new()
		figure.name = "Figure%d" % i
		figure.mesh = _figure_mesh(tuning.seed + i)
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color(tuning.figure_color, 0.0)
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.roughness = 1.0
		mat.vertex_color_use_as_albedo = false
		figure.material_override = mat
		figure.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		figure.position = Vector3(xz.x, layout.height_at(xz.x, xz.y), xz.y)
		# Facing the huaca.
		var to: Vector2 = layout.huaca - xz
		figure.rotation.y = atan2(to.x, to.y)
		_figures.add_child(figure)


## A standing stone shaped like a warrior: a tall body stone and a head stone.
func _figure_mesh(seed: int) -> ArrayMesh:
	# A rock is 2 × radius × squash tall, standing on y = 0.
	var h: float = tuning.figure_height
	var body: ArrayMesh = LowPolyMesh.rock(0.38, h * 0.8 / 0.76, seed, Color.WHITE, 0.2)
	var head: ArrayMesh = LowPolyMesh.rock(0.19, 1.0, seed + 50, Color.WHITE, 0.15)
	var at_head := Transform3D(Basis.IDENTITY, Vector3(0.0, h * 0.78, 0.0))
	return KitWalls.merge([[body, Transform3D.IDENTITY], [head, at_head]])


func _face_figures(marker: StringName) -> void:
	if camera_rig == null:
		return
	var huaca: Vector3 = level.marker_position(marker)
	var centre: Vector2 = level.layout.huaca + Vector2(0.0, tuning.distance_max)
	var target: Vector3 = level.to_global_point(centre)
	var dir: Vector3 = target - huaca
	camera_rig.yaw = atan2(-dir.x, -dir.z)
	camera_rig.pitch = -0.12
	# Cusi turns to them too (the player's front is -Z).
	player.rotation.y = camera_rig.yaw
