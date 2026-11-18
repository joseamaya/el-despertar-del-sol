class_name SliceDirector
extends Node
## Plays the vertical slice step by step (F4 task 2, GDD §14.1): starts each encounter
## zone, notices when the player reaches a place, moves the respawn point to the latest
## checkpoint, and says when the slice is over. Tasks 3–7 hang dialogue, the huaca, the
## Apoyo choice and the ending on its signals.

signal act_changed(act: SliceStep.Act)
signal step_started(step: SliceStep)
signal checkpoint_reached(marker: StringName)
signal slice_finished

const ACTION_RESTART: StringName = &"restart"

@export var sequence: SliceSequence
@export var level: SectorLevel
@export var arena: ArenaController
## Plays the DIALOGUE steps (F4 task 3). Needed only if the sequence has any.
@export var dialogue: DialoguePlayer
## INTERACT and RITE steps (F4 task 4). Needed only if the sequence has any.
@export var interaction: InteractionPoint
@export var rite: HuacaRite
## Off for tools that drive the zones themselves (benchmark, captures).
@export var autostart: bool = true

var flow: SliceFlow
var _waited: float = 0.0
var _act: int = -1
var _checkpoint: StringName = &""


func _ready() -> void:
	assert(sequence != null and level != null and arena != null, "SliceDirector: parts.")
	arena.zone_won.connect(_on_zone_won)
	if dialogue != null:
		dialogue.dialogue_finished.connect(_on_dialogue_finished)
	if interaction != null:
		interaction.interacted.connect(_on_kind_done.bind(SliceStep.Kind.INTERACT).unbind(1))
	if rite != null:
		rite.rite_finished.connect(_on_kind_done.bind(SliceStep.Kind.RITE))
	# After the level and the arena have set up the sector and the first respawn.
	if autostart:
		_begin.call_deferred()


func _physics_process(delta: float) -> void:
	var step: SliceStep = flow.current() if flow != null else null
	if step == null:
		return
	match step.kind:
		SliceStep.Kind.WAIT:
			_waited += delta
			if _waited >= step.seconds:
				_complete()
		SliceStep.Kind.REACH:
			var to: Vector3 = level.marker_position(step.marker) - arena.player.global_position
			if Vector2(to.x, to.z).length() <= step.radius:
				_complete()


func _unhandled_input(event: InputEvent) -> void:
	if flow != null and flow.is_finished() and event.is_action_pressed(ACTION_RESTART):
		get_tree().reload_current_scene()


func is_finished() -> bool:
	return flow != null and flow.is_finished()


func _begin() -> void:
	flow = SliceFlow.new(sequence)
	_start(flow.current())


func _start(step: SliceStep) -> void:
	if step == null:
		slice_finished.emit()
		return
	_waited = 0.0
	if step.act != _act:
		_act = step.act
		act_changed.emit(step.act)
	var marker: StringName = flow.checkpoint()
	if marker != &"" and marker != _checkpoint:
		_checkpoint = marker
		arena.player_spawn = level.marker_node(marker)
		checkpoint_reached.emit(marker)
	step_started.emit(step)
	match step.kind:
		SliceStep.Kind.ENCOUNTER:
			if arena.is_zone_won(step.zone):
				_complete()
			else:
				arena.start_zone(step.zone)
		SliceStep.Kind.DIALOGUE:
			assert(dialogue != null, "SliceDirector: a DIALOGUE step needs the player.")
			dialogue.play(step.dialogue)
		SliceStep.Kind.INTERACT:
			assert(interaction != null, "SliceDirector: an INTERACT step needs the point.")
			interaction.activate(step.marker, step.radius, step.prompt)
		SliceStep.Kind.RITE:
			assert(rite != null, "SliceDirector: a RITE step needs the rite.")
			rite.perform(step.marker)


func _complete() -> void:
	_start(flow.advance())


func _on_dialogue_finished() -> void:
	_on_kind_done(SliceStep.Kind.DIALOGUE)


## Completes the current step if it is of `kind` (signals of dialogue, interaction, rite).
func _on_kind_done(kind: SliceStep.Kind) -> void:
	var step: SliceStep = flow.current() if flow != null else null
	if step != null and step.kind == kind:
		_complete()


func _on_zone_won(zone: int) -> void:
	var step: SliceStep = flow.current() if flow != null else null
	if step != null and step.kind == SliceStep.Kind.ENCOUNTER and step.zone == zone:
		_complete()
