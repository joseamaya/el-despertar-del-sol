class_name SliceDirector
extends Node
## Plays the vertical slice step by step (F4 task 2, GDD §14.1): starts each encounter
## zone, notices when the player reaches a place, moves the respawn point to the latest
## checkpoint, and says when the slice is over. Tasks 3–7 hang dialogue, the huaca, the
## Apoyo choice and the ending on its signals; choices set flags that later steps and
## other systems read (`has_flag`).

signal act_changed(act: SliceStep.Act)
signal step_started(step: SliceStep)
signal checkpoint_reached(marker: StringName)
signal slice_finished
## A step with a notice completed: show it (translation key).
signal notice_shown(key: StringName)

const ACTION_RESTART: StringName = &"restart"
## Shown dimmed at the next interaction while a skirmish is still on.
const LOCKED_PROMPT: StringName = &"PROMPT_ENEMIES_NEAR"

@export var sequence: SliceSequence
@export var level: SectorLevel
@export var arena: ArenaController
## Plays the DIALOGUE steps (F4 task 3). Needed only if the sequence has any.
@export var dialogue: DialoguePlayer
## INTERACT and RITE steps (F4 task 4). Needed only if the sequence has any.
@export var interaction: InteractionPoint
@export var rite: HuacaRite
## CHOICE steps (F4 task 6). Needed only if the sequence has any.
@export var choice: ChoiceBox
## DRILL steps (F4 task 12a). Needed only if the sequence has any.
@export var drill: TrainingDrill
## Off for tools that drive the zones themselves (benchmark, captures).
@export var autostart: bool = true

var flow: SliceFlow
## Seconds of play since the slice began, frozen at its end; pauses do not count
## (F4 task 12: the 8–12 min of the exit criterion).
var play_time: float = 0.0
var _waited: float = 0.0
var _act: int = -1
var _checkpoint: StringName = &""


func _ready() -> void:
	assert(sequence != null and level != null and arena != null, "SliceDirector: parts.")
	arena.zone_won.connect(_on_zone_won)
	arena.reinforcements_called.connect(_on_reinforcements_called)
	if dialogue != null:
		dialogue.dialogue_finished.connect(_on_dialogue_finished)
	if interaction != null:
		interaction.interacted.connect(_on_kind_done.bind(SliceStep.Kind.INTERACT).unbind(1))
	if rite != null:
		rite.rite_finished.connect(_on_kind_done.bind(SliceStep.Kind.RITE))
	if choice != null:
		choice.chosen.connect(_on_chosen)
	if drill != null:
		drill.drill_done.connect(_on_kind_done.bind(SliceStep.Kind.DRILL))
	# After the level and the arena have set up the sector and the first respawn.
	if autostart:
		_begin.call_deferred()


func _physics_process(delta: float) -> void:
	var step: SliceStep = flow.current() if flow != null else null
	if step == null:
		return
	play_time += delta / maxf(Engine.time_scale, 0.0001)
	match step.kind:
		SliceStep.Kind.WAIT:
			_waited += delta
			if _waited >= step.seconds:
				_complete()
		SliceStep.Kind.REACH:
			if _reached(step):
				_complete()
	_skip_if_passed(step)


func _unhandled_input(event: InputEvent) -> void:
	if flow != null and flow.is_finished() and event.is_action_pressed(ACTION_RESTART):
		get_tree().reload_current_scene()


func is_finished() -> bool:
	return flow != null and flow.is_finished()


## Shows a banner from elsewhere in the slice (the comuneros arriving, F4 task 6).
func announce(key: StringName) -> void:
	notice_shown.emit(key)


## The number an objective shows: warriors left in a fight, repetitions left in a drill.
func objective_count() -> int:
	var step: SliceStep = flow.current() if flow != null else null
	if step == null:
		return 0
	if step.kind == SliceStep.Kind.DRILL and drill != null:
		return drill.remaining()
	return arena.alive_enemies().size()


## Whether a choice or a step has set `flag` (false before the slice starts).
func has_flag(flag: StringName) -> bool:
	return flow != null and flow.has_flag(flag)


func _begin() -> void:
	flow = SliceFlow.new(sequence)
	_start(flow.current())


func _reached(step: SliceStep) -> bool:
	var to: Vector3 = level.marker_position(step.marker) - arena.player.global_position
	return Vector2(to.x, to.z).length() <= step.radius


## The player walked past an optional step that waits for them (the huaca) and reached
## the next place: leave it undone and go on from there.
func _skip_if_passed(step: SliceStep) -> void:
	if flow.current() != step or step.kind not in [SliceStep.Kind.INTERACT, SliceStep.Kind.REACH]:
		return
	var ahead: SliceStep = flow.next_required()
	if ahead == null or ahead.kind != SliceStep.Kind.REACH or not _reached(ahead):
		return
	if interaction != null and step.kind == SliceStep.Kind.INTERACT:
		interaction.deactivate()
	_start(flow.skip_optional())


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
				_lock_next_interaction()
		SliceStep.Kind.DIALOGUE:
			assert(dialogue != null, "SliceDirector: a DIALOGUE step needs the player.")
			dialogue.play(step.dialogue)
		SliceStep.Kind.INTERACT:
			assert(interaction != null, "SliceDirector: an INTERACT step needs the point.")
			interaction.activate(step.marker, step.radius, step.prompt)
		SliceStep.Kind.RITE:
			assert(rite != null, "SliceDirector: a RITE step needs the rite.")
			rite.perform(step.marker)
		SliceStep.Kind.CHOICE:
			assert(choice != null, "SliceDirector: a CHOICE step needs the box.")
			choice.ask(step.choice)
		SliceStep.Kind.DRILL:
			# TrainingDrill starts it from step_started and says when it is done.
			assert(drill != null, "SliceDirector: a DRILL step needs the training.")


## What comes after a skirmish (the huaca, the llamas) says it must wait meanwhile.
func _lock_next_interaction() -> void:
	var next: SliceStep = flow.peek_next()
	if interaction != null and next != null and next.kind == SliceStep.Kind.INTERACT:
		interaction.lock(next.marker, next.radius, LOCKED_PROMPT)


func _complete(extra_flag: StringName = &"") -> void:
	var notice: StringName = flow.current().notice
	var next: SliceStep = flow.advance(extra_flag)
	if notice != &"":
		notice_shown.emit(notice)
	_start(next)


func _on_dialogue_finished() -> void:
	_on_kind_done(SliceStep.Kind.DIALOGUE)


## Completes the current step if it is of `kind` (signals of dialogue, interaction, rite).
func _on_kind_done(kind: SliceStep.Kind) -> void:
	var step: SliceStep = flow.current() if flow != null else null
	if step != null and step.kind == kind:
		_complete()


func _on_chosen(index: int) -> void:
	var step: SliceStep = flow.current() if flow != null else null
	if step != null and step.kind == SliceStep.Kind.CHOICE:
		_complete(step.choice.options[index].flag)


func _on_reinforcements_called(zone: int) -> void:
	var step: SliceStep = flow.current() if flow != null else null
	if step != null and step.kind == SliceStep.Kind.ENCOUNTER and step.zone == zone:
		if step.wave_notice != &"":
			notice_shown.emit(step.wave_notice)


func _on_zone_won(zone: int) -> void:
	var step: SliceStep = flow.current() if flow != null else null
	if step != null and step.kind == SliceStep.Kind.ENCOUNTER and step.zone == zone:
		_complete()
