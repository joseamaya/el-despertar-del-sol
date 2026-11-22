class_name TrainingDrill
extends Node
## Vicaquirao's training at the lookout (F4 task 12a, GDD §5.2): while the slice is on a
## DRILL step he spars with Cusi (a warrior on his own side: slow blows that do no harm)
## and counts what the step asks for: blocks, parries, dodges, hits on him. A dodge
## started while his blow is coming counts, whether the roll takes Cusi through the blow
## or out of its reach. Between drills he stands still; when the training is over he goes
## back to being the standing Vicaquirao. In the parry drill, enough plain blocks also
## end it (`parry_grace_blocks`), so nobody gets stuck on the timing.

signal progressed(done: int, needed: int)
signal drill_done

const BODY_PATH: NodePath = ^"Visual/Model/Armature/GeneralSkeleton/Mannequin"

@export var tuning: TrainingDrillTuning
## The warrior scene, configured as Vicaquirao by code.
@export var trainer_scene: PackedScene
@export var slice: SliceDirector
@export var player: PlayerController
## The standing Vicaquirao: hidden while he trains.
@export var npc: Node3D

var _trainer: EnemyController
var _step: SliceStep
var _done: int = 0
## Each of his blows counts for one dodge at most.
var _blow_dodged: bool = false
## Plain blocks made during the current parry drill.
var _parry_blocks: int = 0


func _ready() -> void:
	assert(tuning != null and trainer_scene != null, "TrainingDrill: tuning and scene.")
	assert(slice != null and player != null and npc != null, "TrainingDrill: parts.")
	slice.step_started.connect(_on_step_started)
	var defense := player.get_node(^"Defense") as DefenseComponent
	defense.blocked.connect(_on_event.bind(SliceStep.Drill.BLOCK).unbind(1))
	defense.parried.connect(_on_event.bind(SliceStep.Drill.PARRY).unbind(1))
	defense.evaded.connect(_on_dodged.unbind(1))
	defense.dodge_started.connect(_on_dodge_started)


func trainer() -> EnemyController:
	return _trainer


func is_training() -> bool:
	return _trainer != null


## What the current drill still needs (0 outside drills).
func remaining() -> int:
	return maxi(0, _step.count - _done) if _step != null else 0


## Counts one of the player's moves towards the current drill. Public so tests can drive
## it without real blows.
func count(drill: SliceStep.Drill) -> void:
	if _step == null or drill != _step.drill:
		return
	_done += 1
	progressed.emit(_done, _step.count)
	if _done >= _step.count:
		_step = null
		_set_sparring(false)
		drill_done.emit()


func _on_event(drill: SliceStep.Drill) -> void:
	# A parry is also a block.
	if drill == SliceStep.Drill.PARRY and _step != null and _step.drill == SliceStep.Drill.BLOCK:
		count(SliceStep.Drill.BLOCK)
		return
	if drill == SliceStep.Drill.BLOCK and _step != null and _step.drill == SliceStep.Drill.PARRY:
		_on_parry_missed()
		return
	count(drill)


## A plain block in the parry drill: enough of them end it all the same.
func _on_parry_missed() -> void:
	_parry_blocks += 1
	if tuning.parry_grace_blocks > 0 and _parry_blocks >= tuning.parry_grace_blocks:
		count(SliceStep.Drill.PARRY)


func _on_dodge_started() -> void:
	if _trainer != null and _trainer.combat.is_attacking():
		_on_dodged()


func _on_dodged() -> void:
	if _blow_dodged:
		return
	_blow_dodged = true
	count(SliceStep.Drill.EVADE)


func _on_step_started(step: SliceStep) -> void:
	if step.kind == SliceStep.Kind.DRILL:
		if _trainer == null:
			_spawn()
		_step = step
		_done = 0
		_parry_blocks = 0
		_set_sparring(true)
		progressed.emit(0, step.count)
	elif step.kind != SliceStep.Kind.DIALOGUE and _trainer != null:
		_dismiss()


func _set_sparring(on: bool) -> void:
	if _trainer == null:
		return
	_trainer.perception.target = player if on else null


func _spawn() -> void:
	_trainer = trainer_scene.instantiate() as EnemyController
	_trainer.name = "VicaquiraoTrainer"
	var data: EnemyData = tuning.data
	_trainer.data = data
	(_trainer.get_node(^"Perception") as PerceptionComponent).data = data
	(_trainer.get_node(^"Guard") as EnemyGuard).data = data
	(_trainer.get_node(^"Combat") as EnemyCombat).data = data
	(_trainer.get_node(^"Health") as HealthComponent).tuning = data.health
	(_trainer.get_node(^"Posture") as PostureComponent).tuning = data.posture
	(_trainer.get_node(^"AlertMarker") as Node3D).visible = false
	_trainer.alert_marker = null
	_trainer.director = null
	(_trainer.get_node(BODY_PATH) as GeometryInstance3D).material_override = null
	if tuning.look != null:
		CharacterOutfit.apply(_trainer.get_node(^"Visual/Model") as Node3D, tuning.look)
	_trainer.position = npc.global_position + Vector3.UP * 0.1
	_trainer.rotation.y = npc.global_rotation.y + PI
	add_child(_trainer)
	(_trainer.get_node(^"Hurtbox") as Hurtbox).hit_received.connect(_on_trainer_hit)
	_trainer.combat.attack_started.connect(func(_a: AttackData) -> void: _blow_dodged = false)
	npc.visible = false


func _dismiss() -> void:
	_trainer.queue_free()
	_trainer = null
	_step = null
	npc.visible = true


func _on_trainer_hit(_info: HitInfo) -> void:
	# He never falls in training.
	_trainer.health.reset()
	count(SliceStep.Drill.HIT)
