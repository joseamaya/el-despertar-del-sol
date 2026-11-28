class_name EscortParty
extends Node3D
## The people Cusi frees and leads to safety (F10 task 5, mission B's prisoners). They
## sit tied at their markers until the InteractionPoint there frees them; from then on
## they follow Cusi, a few steps behind, and crouch while a fight is on. A Chanca goes for
## one of them only when Cusi is far from them, and back to Cusi when he returns. If one
## falls, the fight is lost as if Cusi had fallen: the retry brings them all back beside
## him, whole. An ESCORT step is done when Cusi and every one of them stand at its marker.

signal freed(marker: StringName)
signal arrived
signal member_fell

@export var tuning: EscortTuning
@export var prisoner_scene: PackedScene
@export var level: SectorLevel
@export var arena: ArenaController
@export var slice: SliceDirector
@export var interaction: InteractionPoint
## The markers (layout points) where they sit tied, one each.
@export var markers: Array[StringName] = []

var _members: Array[Prisoner] = []
## Chanca drawn to a prisoner -> that prisoner.
var _drawn: Dictionary[EnemyController, Prisoner] = {}
var _arrived_step: SliceStep = null


func _ready() -> void:
	assert(tuning != null and prisoner_scene != null, "EscortParty: tuning and scene.")
	assert(level != null and arena != null and slice != null, "EscortParty: parts.")
	if interaction != null:
		interaction.interacted.connect(_on_interacted)
	arena.encounter_started.connect(_on_encounter_started)
	# After the level has built the sector and its markers.
	_spawn_all.call_deferred()


func members() -> Array[Prisoner]:
	return _members


func free_members() -> Array[Prisoner]:
	var out: Array[Prisoner] = []
	for p: Prisoner in _members:
		if not p.tied:
			out.append(p)
	return out


## The prisoner tied at `marker`, or null.
func member_at(marker: StringName) -> Prisoner:
	var i: int = markers.find(marker)
	return _members[i] if i >= 0 and i < _members.size() else null


func _physics_process(_delta: float) -> void:
	var followers: Array[Prisoner] = free_members()
	if followers.is_empty():
		return
	var fighting: bool = arena.is_in_combat()
	var player: Node3D = arena.player
	var forward: Vector3 = _away_from(followers)
	for i: int in followers.size():
		var p: Prisoner = followers[i]
		if fighting:
			p.crouch()
		else:
			p.go_to(
				EscortRules.follow_slot(
					player.global_position,
					forward,
					i,
					followers.size(),
					tuning.follow_distance,
					tuning.spacing
				)
			)
	_guard(followers)
	_check_arrival(followers)


## Chancas near an unguarded prisoner go for them; back to Cusi once he is close again.
func _guard(followers: Array[Prisoner]) -> void:
	var player: Node3D = arena.player
	for enemy: EnemyController in arena.alive_enemies():
		var sense: PerceptionComponent = enemy.perception
		if _drawn.has(enemy):
			var p: Prisoner = _drawn[enemy]
			var safe: bool = (
				p.health.is_dead()
				or not EscortRules.threatens(
					player.global_position,
					p.global_position,
					enemy.global_position,
					tuning.protect_radius,
					tuning.threat_radius
				)
			)
			if safe:
				_drawn.erase(enemy)
				sense.target = player
			continue
		if sense.target != player:
			continue
		for p: Prisoner in followers:
			if p.health.is_dead():
				continue
			if EscortRules.threatens(
				player.global_position,
				p.global_position,
				enemy.global_position,
				tuning.protect_radius,
				tuning.threat_radius
			):
				_drawn[enemy] = p
				sense.target = p
				sense.alert_to(p.global_position)
				break


func _check_arrival(followers: Array[Prisoner]) -> void:
	var step: SliceStep = slice.flow.current() if slice.flow != null else null
	if step == null or step.kind != SliceStep.Kind.ESCORT or step == _arrived_step:
		return
	var points := PackedVector3Array([arena.player.global_position])
	for p: Prisoner in followers:
		points.append(p.global_position)
	if EscortRules.all_within(points, level.marker_position(step.marker), step.radius):
		_arrived_step = step
		arrived.emit()


## Where Cusi heads, as seen by the ones following: from their middle to him. They keep
## to the side they are on instead of swinging round each time he turns.
func _away_from(followers: Array[Prisoner]) -> Vector3:
	var middle := Vector3.ZERO
	for p: Prisoner in followers:
		middle += p.global_position
	middle /= followers.size()
	var to: Vector3 = arena.player.global_position - middle
	to.y = 0.0
	return to if to.length_squared() > 0.01 else Vector3.FORWARD


func _spawn_all() -> void:
	for marker: StringName in markers:
		var p := prisoner_scene.instantiate() as Prisoner
		p.name = "Prisoner_%s" % marker
		add_child(p)
		p.global_position = level.marker_position(marker) + Vector3.UP * 0.05
		p.setup(tuning)
		p.health.died.connect(_on_member_died)
		_members.append(p)


func _on_interacted(marker: StringName) -> void:
	var p: Prisoner = member_at(marker)
	if p == null or not p.tied:
		return
	p.untie()
	freed.emit(marker)


func _on_member_died() -> void:
	member_fell.emit()
	arena.lose()


## A (re)start of the fight: after a defeat the freed ones are back beside Cusi, whole.
func _on_encounter_started() -> void:
	_drawn.clear()
	var followers: Array[Prisoner] = free_members()
	var player: Node3D = arena.player
	var forward: Vector3 = _away_from(followers)
	for i: int in followers.size():
		var slot: Vector3 = EscortRules.follow_slot(
			player.global_position,
			forward,
			i,
			followers.size(),
			tuning.follow_distance,
			tuning.spacing
		)
		var map: RID = get_world_3d().navigation_map
		followers[i].revive(NavigationServer3D.map_get_closest_point(map, slot) + Vector3.UP * 0.1)
