class_name TrainingDummy
extends Node3D
## Test-scene target: flashes red when hit, turns yellow and leans while its posture is
## broken (executable), and disappears when its health runs out.

@export var health: HealthComponent
@export var hurtbox: Hurtbox
@export var posture: PostureComponent
@export var mesh: MeshInstance3D
@export var flash_color: Color = Color(0.9, 0.15, 0.1)
@export var broken_color: Color = Color(0.95, 0.8, 0.15)
@export_range(0.01, 1.0, 0.01, "suffix:s") var flash_time: float = 0.12
@export_range(0.0, 45.0, 1.0, "suffix:°") var broken_lean_deg: float = 14.0

var _flash_material: StandardMaterial3D
var _broken_material: StandardMaterial3D


func _ready() -> void:
	assert(health != null and hurtbox != null, "TrainingDummy needs health and hurtbox.")
	_flash_material = _unshaded(flash_color)
	_broken_material = _unshaded(broken_color)
	hurtbox.hit_received.connect(_on_hit)
	health.died.connect(_on_died)
	if posture != null:
		posture.posture_broken.connect(_on_posture_broken)
		posture.posture_recovered.connect(_on_posture_recovered)


func is_flashing() -> bool:
	return mesh != null and mesh.material_override == _flash_material


func shows_broken() -> bool:
	return mesh != null and mesh.material_override == _broken_material


func _on_hit(_info: HitInfo) -> void:
	if mesh == null:
		return
	mesh.material_override = _flash_material
	await get_tree().create_timer(flash_time, false).timeout
	if is_instance_valid(mesh):
		mesh.material_override = _resting_material()


func _on_posture_broken() -> void:
	if mesh != null:
		mesh.material_override = _broken_material
		mesh.rotation_degrees.x = broken_lean_deg


func _on_posture_recovered() -> void:
	if mesh != null:
		mesh.material_override = null
		mesh.rotation_degrees.x = 0.0


func _resting_material() -> Material:
	return _broken_material if posture != null and posture.is_broken() else null


func _on_died() -> void:
	queue_free()


func _unshaded(color: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	return m
