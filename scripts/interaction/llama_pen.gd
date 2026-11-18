class_name LlamaPen
extends Node3D
## The family's stolen llamas, tied in a corral past the houses (F4 task 6). When the
## player frees them (the InteractionPoint at their marker) they trot out of the corral
## and stay grazing outside. No AI and no collision: they are scenery with one moment.

signal llamas_freed

@export var tuning: LlamaPenTuning
@export var level: SectorLevel
## Optional: the point whose interaction at `marker` frees them.
@export var interaction: InteractionPoint
@export var marker: StringName = &"Llamas"

var _llamas: Array[MeshInstance3D] = []
var _homes: PackedVector2Array = PackedVector2Array()
var _free: bool = false


func _ready() -> void:
	assert(tuning != null and level != null, "LlamaPen: parts.")
	if interaction != null:
		interaction.interacted.connect(_on_interacted)
	# After the level has built the sector.
	_build.call_deferred()


func is_free() -> bool:
	return _free


func llamas() -> Array[MeshInstance3D]:
	return _llamas


## The llamas' places inside the corral (layout x, z). Pure.
static func pen_places(centre: Vector2, radius: float, t: LlamaPenTuning) -> PackedVector2Array:
	var rng := RandomNumberGenerator.new()
	rng.seed = t.seed
	var out := PackedVector2Array()
	for i: int in t.count:
		var angle: float = TAU * (float(i) + rng.randf_range(-0.2, 0.2)) / t.count
		var dist: float = radius * t.spread * rng.randf_range(0.5, 1.0)
		out.append(centre + Vector2(sin(angle), cos(angle)) * dist)
	return out


## Sends them out of the corral. Does nothing the second time.
func free_llamas() -> void:
	if _free:
		return
	_free = true
	for i: int in _llamas.size():
		var from: Vector2 = _homes[i]
		var to: Vector2 = from + Vector2((i - (_llamas.size() - 1) * 0.5) * 2.0, 0.0)
		to.y += tuning.trot_distance
		var llama: MeshInstance3D = _llamas[i]
		llama.rotation.y = atan2(to.x - from.x, to.y - from.y)
		var trot := create_tween()
		trot.tween_interval(0.3 * i)
		trot.tween_method(_place.bind(llama, from, to), 0.0, 1.0, tuning.trot_time)
	llamas_freed.emit()


func _build() -> void:
	var layout: SectorLayout = level.layout
	var centre: Vector2 = layout.llamas
	var radius: float = 3.0
	for c: Vector3 in layout.corrals:
		if Vector2(c.x, c.y).distance_to(centre) < 0.5:
			radius = c.z
	_homes = pen_places(centre, radius, tuning)
	var rng := RandomNumberGenerator.new()
	rng.seed = tuning.seed
	for i: int in _homes.size():
		var wool: Color = tuning.wool[i % tuning.wool.size()]
		var llama := SectorBuilder.add_mesh(
			self,
			"Llama%d" % i,
			KitAnimals.llama(wool, tuning.dark, tuning.seed + i),
			level.palette,
			Vector3.ZERO
		)
		llama.rotation.y = rng.randf_range(-PI, PI)
		_llamas.append(llama)
		_place(0.0, llama, _homes[i], _homes[i])


func _place(t: float, llama: MeshInstance3D, from: Vector2, to: Vector2) -> void:
	var xz: Vector2 = from.lerp(to, t)
	var bob: float = absf(sin(t * tuning.trot_time * TAU * 1.5)) * tuning.bob
	if t <= 0.0 or t >= 1.0:
		bob = 0.0
	var at: Vector3 = level.to_global_point(xz)
	llama.global_position = at + Vector3.UP * bob


func _on_interacted(at: StringName) -> void:
	if at == marker:
		free_llamas()
