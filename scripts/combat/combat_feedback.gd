class_name CombatFeedback
extends Node3D
## Player-facing impact feedback (GDD §6.1, §12.4): camera shake when hurt or landing heavy
## hits, a longer freeze and a flash on parries, and the biggest punch on executions.
## Lives in the level; every source is injected.

signal parry_flashed(at: Vector3)

@export var feel: CombatFeelTuning
@export var hit_stop: HitStop
@export var camera_rig: CameraController
@export var player_hurtbox: Hurtbox
@export var player_hitbox: Hitbox
@export var player_defense: DefenseComponent
@export var player_combat: CombatComponent


func _ready() -> void:
	assert(feel != null, "CombatFeedback needs a CombatFeelTuning resource.")
	if player_hurtbox != null:
		player_hurtbox.hit_received.connect(_on_player_hurt)
	if player_hitbox != null:
		player_hitbox.hit_landed.connect(_on_player_hit_landed)
	if player_defense != null:
		player_defense.parried.connect(_on_parried)
	if player_combat != null:
		player_combat.executed.connect(_on_executed)


func _on_player_hurt(_info: HitInfo) -> void:
	_shake(feel.shake_on_hurt)


func _on_player_hit_landed(_hurtbox: Hurtbox, info: HitInfo) -> void:
	if info.posture_damage >= feel.heavy_threshold:
		_shake(feel.shake_on_heavy_hit)


func _on_parried(info: HitInfo) -> void:
	if hit_stop != null:
		hit_stop.trigger(feel.parry_hitstop)
	_shake(feel.shake_on_parry)
	var at: Vector3 = info.point
	if at.is_zero_approx() and player_hurtbox != null:
		at = player_hurtbox.global_position + Vector3.UP * 0.4
	_flash(at)


func _on_executed(_target: Hurtbox) -> void:
	if hit_stop != null:
		hit_stop.trigger(feel.execution_hitstop)
	_shake(feel.shake_on_execution)


func _shake(amount: float) -> void:
	if camera_rig != null:
		camera_rig.add_shake(amount)


func _flash(at: Vector3) -> void:
	var material := StandardMaterial3D.new()
	material.albedo_color = feel.parry_flash_color
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	var sphere := SphereMesh.new()
	sphere.radius = 0.5
	sphere.height = 1.0
	sphere.material = material
	var flash := MeshInstance3D.new()
	flash.mesh = sphere
	flash.top_level = true
	add_child(flash)
	flash.global_position = at
	flash.scale = Vector3.ONE * 0.1
	var tween: Tween = flash.create_tween().set_parallel(true).set_ignore_time_scale(true)
	tween.tween_property(flash, "scale", Vector3.ONE * feel.parry_flash_size, feel.parry_flash_time)
	tween.tween_property(material, "albedo_color:a", 0.0, feel.parry_flash_time)
	tween.chain().tween_callback(flash.queue_free)
	parry_flashed.emit(at)
