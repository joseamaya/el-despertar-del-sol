class_name ResponseProbe
extends Node
## Diagnostic helper (F6 tasks 6–7): presses attack and dodge for a bot and, for every
## press, records whether the game started it at once, kept it for later, or dropped it,
## and why (dodging, attacking, too early in the chain, out of stamina, stunned). A kept
## press that never starts counts as expired. Also counts the blows that land shortly
## after a dodge was lost. Not part of the game: tools/response_diagnosis.gd adds it.

const STARTED: String = "inmediata"
const BUFFERED: String = "guardada"
## A kept press that ran out of time without starting.
const EXPIRED: String = "guardada_caducada"
## The game's refusal reasons, as the report names them.
const REASONS: Dictionary = {
	&"attacking": "atacando",
	&"dodging": "durante_esquiva",
	&"stamina": "sin_resistencia",
	&"stunned": "aturdido",
}
## How soon after a dropped dodge a landed blow counts as its cost.
const COST_WINDOW: float = 0.6

@export var player: PlayerController

var presses: Dictionary = {"ataque": {}, "esquiva": {}}
## Seconds a buffered attack waited, one per buffered press.
var buffer_waits: PackedFloat32Array = PackedFloat32Array()
var hits_after_dropped_dodge: int = 0
var hits: int = 0

var _combat: CombatComponent
var _defense: DefenseComponent
var _stamina: StaminaComponent
var _clock: float = 0.0
var _last_dropped_dodge: float = -INF
var _dodge_kept: bool = false
var _attack_kept: bool = false


func _ready() -> void:
	assert(player != null, "ResponseProbe needs the player.")
	_combat = player.get_node(^"Combat") as CombatComponent
	_defense = player.get_node(^"Defense") as DefenseComponent
	_stamina = player.get_node(^"Stamina") as StaminaComponent
	(player.get_node(^"Hurtbox") as Hurtbox).hit_received.connect(_on_hit)


func _physics_process(delta: float) -> void:
	_clock += delta
	if _dodge_kept and not _defense.is_dodge_waiting():
		_dodge_kept = false
		if not _defense.is_dodging():
			_count("esquiva", EXPIRED)
			_last_dropped_dodge = _clock
	if _attack_kept and not _combat.is_attack_waiting():
		_attack_kept = false
		if not _combat.is_attacking():
			_count("ataque", EXPIRED)


## Presses an attack of `kind` and records what became of it.
func press_attack(kind: CombatComponent.Kind) -> String:
	var outcome: String = attack_outcome()
	if outcome == BUFFERED and _combat.is_attacking():
		var data: AttackData = _combat.get_current()
		buffer_waits.append(maxf(0.0, AttackRules.real(data.chain_from, data) - _combat_elapsed()))
	_count("ataque", outcome)
	_combat.request(kind)
	if outcome == BUFFERED and not _combat.is_attacking():
		_attack_kept = _combat.is_attack_waiting()
	return outcome


## Presses dodge, the way the game does, and records what became of it.
func press_dodge() -> String:
	var outcome: String = dodge_outcome()
	var kept: bool = _defense.press_dodge()
	if outcome == STARTED and not kept:
		outcome = "otro"
	if outcome == BUFFERED:
		_dodge_kept = true
	elif outcome != STARTED:
		_last_dropped_dodge = _clock
	_count("esquiva", outcome)
	return outcome


## What a light attack pressed now would do.
func attack_outcome() -> String:
	if not _combat.is_attacking():
		if player.is_in_action():
			if _combat.response != null and _combat.response.attack_buffer > 0.0:
				return BUFFERED
			return "durante_esquiva" if _defense.is_dodging() else "aturdido"
		if _stamina.current <= 0.0:
			return "sin_resistencia"
		return STARTED
	var data: AttackData = _combat.get_current()
	if AttackRules.accepts_buffer(_combat_elapsed(), data):
		return BUFFERED
	return "demasiado_pronto"


## What a dodge pressed now would do, by the game's own rule.
func dodge_outcome() -> String:
	var reason: StringName = _defense.dodge_refusal()
	if reason == &"":
		return STARTED
	var keeps: bool = _defense.response != null and _defense.response.dodge_buffer > 0.0
	if keeps and reason in [&"attacking", &"dodging"]:
		return BUFFERED
	return REASONS.get(reason, String(reason)) as String


func report() -> Dictionary:
	return {
		"presses": presses.duplicate(true),
		"buffer_wait_avg": _avg(buffer_waits),
		"buffer_wait_max": _max(buffer_waits),
		"hits": hits,
		"hits_after_dropped_dodge": hits_after_dropped_dodge,
	}


func _combat_elapsed() -> float:
	return _combat.get_elapsed()


func _count(action: String, outcome: String) -> void:
	var table: Dictionary = presses[action]
	table[outcome] = (table.get(outcome, 0) as int) + 1


func _on_hit(_info: HitInfo) -> void:
	hits += 1
	if _clock - _last_dropped_dodge <= COST_WINDOW:
		hits_after_dropped_dodge += 1


func _avg(values: PackedFloat32Array) -> float:
	if values.is_empty():
		return 0.0
	var total: float = 0.0
	for v: float in values:
		total += v
	return total / values.size()


func _max(values: PackedFloat32Array) -> float:
	var best: float = 0.0
	for v: float in values:
		best = maxf(best, v)
	return best
