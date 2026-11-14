class_name Hud
extends CanvasLayer
## Combat HUD (GDD §12.1): player health and stamina, the locked target's posture and
## health with a reticle on it, and the defeat/victory messages. Hides out of combat.
## Every visible text goes through tr() (GDD §12.5).

const FADE_SPEED: float = 2.0
const HIDE_DELAY: float = 3.0

@export var health: HealthComponent
@export var stamina: StaminaComponent
@export var lock_on: LockOnController
@export var camera: Camera3D
## Optional: combat state and end-of-encounter messages.
@export var arena: ArenaController

@export_group("Nodos")
@export var root: Control
@export var health_bar: ProgressBar
@export var stamina_bar: ProgressBar
@export var target_panel: Control
@export var target_posture_bar: ProgressBar
@export var target_health_bar: ProgressBar
@export var reticle: Control
@export var message_panel: Control
@export var message_label: Label
@export var hint_label: Label

var _calm_time: float = 0.0


func _ready() -> void:
	assert(health != null and stamina != null and root != null, "Hud needs its parts.")
	message_panel.visible = false
	target_panel.visible = false
	reticle.visible = false
	if arena != null:
		arena.player_defeated.connect(_show_message.bind(&"HUD_DEFEAT"))
		arena.encounter_won.connect(_show_message.bind(&"HUD_VICTORY"))
		arena.encounter_started.connect(_hide_message)


func _process(delta: float) -> void:
	health_bar.max_value = health.get_maximum()
	health_bar.value = health.current
	stamina_bar.max_value = stamina.get_maximum()
	stamina_bar.value = stamina.current
	_update_target()
	_update_fade(delta)


func is_shown() -> bool:
	return root.modulate.a > 0.5


func _update_target() -> void:
	var target: LockOnTarget = lock_on.get_target() if lock_on != null else null
	var has_target: bool = target != null and is_instance_valid(target)
	target_panel.visible = has_target and target.posture != null
	if target_panel.visible:
		target_posture_bar.max_value = target.posture.get_maximum()
		target_posture_bar.value = target.posture.current
		if target.health != null:
			target_health_bar.max_value = target.health.get_maximum()
			target_health_bar.value = target.health.current
	reticle.visible = false
	if has_target and camera != null:
		var point: Vector3 = target.get_aim_point()
		if not camera.is_position_behind(point):
			reticle.position = camera.unproject_position(point)
			reticle.visible = true


func _update_fade(delta: float) -> void:
	var busy: bool = (
		(arena != null and arena.is_in_combat())
		or health.current < health.get_maximum()
		or stamina.current < stamina.get_maximum()
		or (lock_on != null and lock_on.is_locked())
		or message_panel.visible
	)
	_calm_time = 0.0 if busy else _calm_time + delta
	var target_alpha: float = 1.0 if _calm_time < HIDE_DELAY else 0.0
	root.modulate.a = move_toward(root.modulate.a, target_alpha, FADE_SPEED * delta)


func _show_message(key: StringName) -> void:
	message_label.text = tr(key)
	hint_label.text = tr(&"HUD_RETRY")
	message_panel.visible = true


func _hide_message() -> void:
	message_panel.visible = false
