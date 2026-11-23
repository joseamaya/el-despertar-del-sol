class_name ResponseProbe
extends Node
## Diagnostic helper (F6 task 6): presses attack and dodge for a bot and, for every press,
## records whether the game started it at once, buffered it for later, or dropped it,
## and why (dodging, attacking, too early in the chain, out of stamina, stunned). Also
## counts the blows that land shortly after a dodge was dropped. Not part of the game:
## tools/response_diagnosis.gd adds it.

const STARTED: String = "inmediata"
const BUFFERED: String = "guardada"
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


func _ready() -> void:
	assert(player != null, "ResponseProbe needs the player.")
	_combat = player.get_node(^"Combat") as CombatComponent
	_defense = player.get_node(^"Defense") as DefenseComponent
	_stamina = player.get_node(^"Stamina") as StaminaComponent
	(player.get_node(^"Hurtbox") as Hurtbox).hit_received.connect(_on_hit)


func _physics_process(delta: float) -> void:
	_clock += delta


## Presses an attack of `kind` and records what became of it.
func press_attack(kind: CombatComponent.Kind) -> String:
	var outcome: String = attack_outcome()
	if outcome == BUFFERED:
		var data: AttackData = _combat.get_current()
		buffer_waits.append(maxf(0.0, AttackRules.real(data.chain_from, data) - _combat_elapsed()))
	_count("ataque", outcome)
	_combat.request(kind)
	return outcome


## Presses dodge and records what became of it.
func press_dodge() -> String:
	var outcome: String = dodge_outcome()
	var started: bool = _defense.request_dodge()
	if outcome == STARTED and not started:
		outcome = "otro"
	if outcome != STARTED:
		_last_dropped_dodge = _clock
	_count("esquiva", outcome)
	return outcome


## What a light attack pressed now would do.
func attack_outcome() -> String:
	if not _combat.is_attacking():
		if player.is_in_action():
			return "durante_esquiva" if _defense.is_dodging() else "aturdido"
		if _stamina.current <= 0.0:
			return "sin_resistencia"
		return STARTED
	var data: AttackData = _combat.get_current()
	if AttackRules.accepts_buffer(_combat_elapsed(), data):
		return BUFFERED
	return "demasiado_pronto"


## What a dodge pressed now would do.
func dodge_outcome() -> String:
	if _defense.is_dodging():
		return "durante_esquiva"
	if _defense.is_stunned():
		return "aturdido"
	if _combat.is_attacking() and _combat.get_phase() != AttackRules.Phase.RECOVERY:
		return "atacando_" + ("anticipacion" if _combat.get_phase() == 0 else "golpe")
	if _stamina.current < _defense.tuning.dodge_stamina_cost:
		return "sin_resistencia"
	return STARTED


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
