class_name Hud
extends CanvasLayer
## Combat HUD (GDD §12.1): player health and stamina, the locked target's posture and
## health with a reticle on it, the defeat/victory messages and, in the slice, a banner
## with each act, its notices and the end (F4 tasks 2 and 6). Hides out of combat.
## Every visible text goes through tr() (GDD §12.5).

const FADE_SPEED: float = 2.0
const HIDE_DELAY: float = 3.0
## How long an act banner stays up.
const BANNER_TIME: float = 3.0
## How long a new objective stays up out of combat (in combat it stays).
const OBJECTIVE_TIME: float = 7.0
## Banner text of each SliceStep.Act, in order.
const ACT_KEYS: Array[StringName] = [
	&"SLICE_ACT_OPENING",
	&"SLICE_ACT_EXPLORATION",
	&"SLICE_ACT_SUPPORT",
	&"SLICE_ACT_COMBAT",
	&"SLICE_ACT_ENDING",
]

@export var health: HealthComponent
@export var stamina: StaminaComponent
@export var lock_on: LockOnController
@export var camera: Camera3D
## Optional: combat state and end-of-encounter messages.
@export var arena: ArenaController
## Optional: the slice's acts and its end.
@export var slice: SliceDirector

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
## The current objective of the slice (GDD §12.1, F4 task 6), built here: shown for a
## while when it changes and all through a fight, with the warriors left.
var _objective_panel: PanelContainer
var _objective: Label
var _objective_step: SliceStep
var _objective_left: float = 0.0
## Seconds left for the act banner; 0 when no banner is up.
var _banner_left: float = 0.0


func _ready() -> void:
	assert(health != null and stamina != null and root != null, "Hud needs its parts.")
	message_panel.visible = false
	target_panel.visible = false
	_build_objective()
	reticle.visible = false
	if arena != null:
		arena.player_defeated.connect(_show_message.bind(&"HUD_DEFEAT"))
		arena.encounter_won.connect(_show_message.bind(&"HUD_VICTORY"))
		arena.encounter_started.connect(_hide_message)
	if slice != null:
		slice.act_changed.connect(_show_banner)
		slice.slice_finished.connect(_show_end)
		slice.notice_shown.connect(_show_notice)
		slice.step_started.connect(_on_step_started)


func _process(delta: float) -> void:
	health_bar.max_value = health.get_maximum()
	health_bar.value = health.current
	stamina_bar.max_value = stamina.get_maximum()
	stamina_bar.value = stamina.current
	_update_target()
	_update_objective(delta)
	_update_fade(delta)
	if _banner_left > 0.0:
		_banner_left -= delta
		if _banner_left <= 0.0:
			_hide_message()


func is_shown() -> bool:
	return root.modulate.a > 0.5


func _update_target() -> void:
	var target: LockOnTarget = lock_on.get_target() if lock_on != null else null
	var has_target: bool = (
		target != null
		and is_instance_valid(target)
		and (target.health == null or not target.health.is_dead())
	)
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


func is_showing_objective() -> bool:
	return _objective_panel.visible


func objective_text() -> String:
	return _objective.text


func _build_objective() -> void:
	_objective_panel = PanelContainer.new()
	_objective_panel.name = "Objective"
	_objective_panel.offset_left = 32.0
	_objective_panel.offset_top = 28.0
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.06, 0.05, 0.72)
	style.set_corner_radius_all(4)
	style.content_margin_left = 16.0
	style.content_margin_right = 16.0
	style.content_margin_top = 8.0
	style.content_margin_bottom = 8.0
	_objective_panel.add_theme_stylebox_override(&"panel", style)
	_objective = Label.new()
	_objective.add_theme_font_size_override(&"font_size", 26)
	_objective.add_theme_color_override(&"font_color", Color(0.98, 0.9, 0.7))
	_objective_panel.add_child(_objective)
	_objective_panel.visible = false
	add_child(_objective_panel)


func _on_step_started(step: SliceStep) -> void:
	_objective_step = step if step.objective != &"" else null
	_objective_left = OBJECTIVE_TIME


func _update_objective(delta: float) -> void:
	_objective_left = maxf(0.0, _objective_left - delta)
	var step: SliceStep = _objective_step
	var fighting: bool = (
		step != null
		and step.kind == SliceStep.Kind.ENCOUNTER
		and arena != null
		and arena.is_zone_engaged()
	)
	_objective_panel.visible = step != null and (_objective_left > 0.0 or fighting)
	if _objective_panel.visible:
		var count: int = arena.alive_enemies().size() if arena != null else 0
		_objective.text = tr(step.objective).format({"count": count})


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
	_banner_left = 0.0
	message_label.text = tr(key)
	hint_label.text = tr(&"HUD_RETRY")
	message_panel.visible = true


func _hide_message() -> void:
	_banner_left = 0.0
	message_panel.visible = false


func _show_banner(act: SliceStep.Act) -> void:
	_show_notice(ACT_KEYS[act])


## A slice notice (F4 task 6), shown like an act banner.
func _show_notice(key: StringName) -> void:
	message_label.text = tr(key)
	hint_label.text = ""
	message_panel.visible = true
	_banner_left = BANNER_TIME


func _show_end() -> void:
	_banner_left = 0.0
	message_label.text = tr(&"SLICE_THE_END")
	# Credits that a licence asks for (docs/ASSET_SOURCES.md: the CC BY conch).
	hint_label.text = "%s\n\n%s" % [tr(&"SLICE_PLAY_AGAIN"), tr(&"CREDITS_CONCH")]
	message_panel.visible = true
