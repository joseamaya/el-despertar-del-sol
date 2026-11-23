class_name CombatFeedback
extends Node3D
## Player-facing impact feedback (GDD §6.1, §12.4): camera shake when hurt or landing heavy
## hits, a longer freeze and a flash on parries, a cold flash with sparks on blocked blows
## (F6 task 4), and the biggest punch on executions.
## Lives in the level; every source is injected.

signal parry_flashed(at: Vector3)
signal block_flashed(at: Vector3)

## Height of the guard above the player's feet, where a blocked blow is shown.
const GUARD_HEIGHT: float = 1.2
## How far in front of the player, toward the attacker.
const GUARD_REACH: float = 0.45

@export var feel: CombatFeelTuning
@export var hit_stop: HitStop
@export var camera_rig: CameraController
@export var player_hurtbox: Hurtbox
@export var player_hitbox: Hitbox
@export var player_defense: DefenseComponent
@export var player_combat: CombatComponent
## Optional: where a blocked blow is shown (the head of the mace, raised by the guard pose;
## F6 task 4). Without it, in front of the player toward the attacker.
@export var player_guard_point: Node3D


func _ready() -> void:
	assert(feel != null, "CombatFeedback needs a CombatFeelTuning resource.")
	if player_hurtbox != null:
		player_hurtbox.hit_received.connect(_on_player_hurt)
	if player_hitbox != null:
		player_hitbox.hit_landed.connect(_on_player_hit_landed)
	if player_defense != null:
		player_defense.parried.connect(_on_parried)
		player_defense.blocked.connect(_on_blocked)
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
	_flash(at, feel.parry_flash_color, feel.parry_flash_size, feel.parry_flash_time)
	parry_flashed.emit(at)


func _on_blocked(info: HitInfo) -> void:
	_shake(feel.shake_on_block)
	var at: Vector3 = guard_point(info)
	# Drawn over the body and the mace: from behind they hid it (F6 task 4).
	_flash(at, feel.block_flash_color, feel.block_flash_size, feel.block_flash_time, true)
	_sparks(at)
	block_flashed.emit(at)


## Where a blocked blow meets the guard: the mace head if known, else in front of the
## player toward the attacker.
func guard_point(info: HitInfo) -> Vector3:
	if player_guard_point != null and is_instance_valid(player_guard_point):
		return player_guard_point.global_position
	var origin: Vector3 = (
		player_defense.player.global_position if player_defense != null else global_position
	)
	var to: Vector3 = Vector3.ZERO
	if info.attacker != null and is_instance_valid(info.attacker):
		to = info.attacker.global_position - origin
	elif not info.point.is_zero_approx():
		to = info.point - origin
	to.y = 0.0
	var ahead: Vector3 = (
		to.normalized() * GUARD_REACH if to.length_squared() > 0.0001 else Vector3.ZERO
	)
	return origin + ahead + Vector3.UP * GUARD_HEIGHT


func _on_executed(_target: Hurtbox) -> void:
	if hit_stop != null:
		hit_stop.trigger(feel.execution_hitstop)
	_shake(feel.shake_on_execution)


func _shake(amount: float) -> void:
	if camera_rig != null:
		camera_rig.add_shake(amount)


func _flash(at: Vector3, color: Color, size: float, time: float, on_top: bool = false) -> void:
	var material := _glow(color)
	material.no_depth_test = on_top
	var sphere := SphereMesh.new()
	sphere.radius = 0.5
	sphere.height = 1.0
	sphere.material = material
	var flash := MeshInstance3D.new()
	flash.mesh = sphere
	flash.top_level = true
	add_child(flash)
	flash.global_position = at
	flash.scale = Vector3.ONE * (size * 0.35 if on_top else 0.1)
	var tween: Tween = flash.create_tween().set_parallel(true).set_ignore_time_scale(true)
	tween.tween_property(flash, "scale", Vector3.ONE * size, time)
	tween.tween_property(material, "albedo_color:a", 0.0, time)
	tween.chain().tween_callback(flash.queue_free)


## Short streaks thrown out from `at`, fading as they fly.
func _sparks(at: Vector3) -> void:
	var material := _glow(feel.block_flash_color.lightened(0.3))
	material.no_depth_test = true
	var streak := BoxMesh.new()
	streak.size = Vector3(0.04, 0.04, 0.26)
	streak.material = material
	var time: float = feel.block_flash_time * 1.5
	for i: int in feel.block_sparks:
		var angle: float = TAU * i / maxi(feel.block_sparks, 1)
		var dir := Vector3(cos(angle), 0.6 * sin(angle * 2.0) + 0.3, sin(angle)).normalized()
		var spark := MeshInstance3D.new()
		spark.mesh = streak
		spark.top_level = true
		add_child(spark)
		spark.global_position = at
		spark.look_at(at + dir, Vector3.UP if absf(dir.y) < 0.95 else Vector3.RIGHT)
		var tween: Tween = spark.create_tween().set_parallel(true).set_ignore_time_scale(true)
		tween.tween_property(spark, "global_position", at + dir * feel.block_spark_reach, time)
		tween.tween_property(spark, "scale", Vector3(1.0, 1.0, 0.2), time)
		tween.chain().tween_callback(spark.queue_free)
	var fade: Tween = create_tween().set_ignore_time_scale(true)
	fade.tween_property(material, "albedo_color:a", 0.0, time)


func _glow(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	return material
