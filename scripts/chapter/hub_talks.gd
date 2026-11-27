class_name HubTalks
extends Node
## Taking missions by talking in the hub (F9 task 6, `docs/fases/F9-diseno-centro.md` §3).
## Near someone with something to say, the prompt names them; interact plays what fits the
## state of their mission: the offer and the question (accept or later), the waiting line
## while it is locked, or the thanks once it is done. Accepting asks to play the mission
## (`mission_chosen`, as the doors of F8 did). On the first visit Apo Mayta speaks. The
## objective names who to see next and where they are. The chapter's progress comes from
## the game shell (LevelEntry); without it nobody offers anything.

signal mission_chosen(mission_id: StringName)
signal objective_changed(text: String)

const ACTION_INTERACT: StringName = &"interact"
## Chapter flag set once the arrival has been heard (kept by the saved game).
const ARRIVAL_FLAG: StringName = &"hub_arrival_heard"
## Index of "accept" in `question`.
const ACCEPT: int = 0

@export var level: SectorLevel
@export var player: PlayerController
@export var prompt: InteractionPrompt
@export var dialogue: DialoguePlayer
@export var choice: ChoiceBox
@export var talks: Array[HubTalk] = []
## Asked after an offer: accept first, then "later".
@export var question: DialogueChoice
## Played once, on the first visit (Apo Mayta).
@export var arrival: DialogueScript
## The people standing at the talks' markers, turned towards Cusi when he speaks to them.
@export var people: Array[SectorNpc] = []
@export_range(0.5, 10.0, 0.5, "suffix:m") var radius: float = 3.0
@export_range(0.0, 5.0, 0.1, "suffix:s") var arrival_delay: float = 0.8

## Set by LevelEntry inside the game shell. Null: nobody offers a mission.
var progress: ChapterProgress
var _near: HubTalk
var _busy: bool = false
var _objective: String = ""


func _ready() -> void:
	assert(level != null and player != null and prompt != null, "HubTalks: parts.")
	assert(dialogue != null and choice != null and question != null, "HubTalks: dialogue.")


## Called by LevelEntry once the level is hosted: the arrival, the first time.
func start() -> void:
	_update_objective()
	if progress == null or arrival == null or progress.has_flag(ARRIVAL_FLAG):
		return
	await get_tree().create_timer(arrival_delay, false).timeout
	progress.set_flag(ARRIVAL_FLAG)
	await _play(arrival)
	_update_objective()


func _physics_process(_delta: float) -> void:
	var talk: HubTalk = null if _busy or player.is_held() else nearest_talk()
	if talk == _near:
		return
	_near = talk
	if talk == null:
		prompt.hide_prompt()
	else:
		prompt.show_text(tr(&"TALK_PROMPT").format({"name": tr(talk.speaker)}))


func _unhandled_input(event: InputEvent) -> void:
	if _near != null and not _busy and event.is_action_pressed(ACTION_INTERACT):
		get_viewport().set_input_as_handled()
		talk_to(_near.marker)


## Talks to whoever stands at `marker` (the player's button; tests). Returns the mission
## accepted, or empty.
func talk_to(marker: StringName) -> StringName:
	var talk: HubTalk = talk_at(marker)
	if talk == null or _busy:
		return &""
	_busy = true
	prompt.hide_prompt()
	_near = null
	_turn_to_player(marker)
	var accepted: StringName = &""
	match _state(talk):
		ChapterProgress.MissionState.AVAILABLE:
			await _play(talk.offer)
			if talk.mission != &"":
				choice.ask(question)
				var picked: int = await choice.chosen
				if picked == ACCEPT:
					accepted = talk.mission
		ChapterProgress.MissionState.DONE:
			await _play(talk.thanks)
		_:
			await _play(talk.waiting)
	_busy = false
	if accepted != &"":
		accept(accepted)
	_update_objective()
	return accepted


## Asks to play an open mission (after "accept"; tests). False if it is not open.
func accept(mission_id: StringName) -> bool:
	if progress == null or progress.state(mission_id) != ChapterProgress.MissionState.AVAILABLE:
		return false
	mission_chosen.emit(mission_id)
	_update_objective.call_deferred()
	return true


## The marker of whoever talks nearest to `at` (F10 task 3: coming back from a mission,
## Cusi turns to the curaca who gave it). Empty if nobody talks.
func nearest_marker(at: Vector3) -> StringName:
	var best: StringName = &""
	var best_distance: float = INF
	for marker: StringName in _markers():
		var distance: float = level.marker_position(marker).distance_to(at)
		if distance < best_distance:
			best = marker
			best_distance = distance
	return best


## What fits someone's mission now: the first talk at `marker` with an open mission, else
## one still locked, else one done (several talks can share a marker: Vicaquirao).
func talk_at(marker: StringName) -> HubTalk:
	var best: HubTalk = null
	var best_rank: int = -1
	for talk: HubTalk in talks:
		if talk.marker != marker:
			continue
		var rank: int = _rank(talk)
		if rank > best_rank:
			best = talk
			best_rank = rank
	return best if best_rank > 0 else null


## The talk the player is standing at, or null.
func nearest_talk() -> HubTalk:
	var best: HubTalk = null
	var best_distance: float = radius
	for marker: StringName in _markers():
		var talk: HubTalk = talk_at(marker)
		if talk == null:
			continue
		var to: Vector3 = level.marker_position(marker) - player.global_position
		var distance: float = Vector2(to.x, to.z).length()
		if distance <= best_distance:
			best = talk
			best_distance = distance
	return best


## The missions someone offers now, for tests and the route.
func open_missions() -> Array[StringName]:
	var out: Array[StringName] = []
	for talk: HubTalk in talks:
		if talk.mission != &"" and _state(talk) == ChapterProgress.MissionState.AVAILABLE:
			out.append(talk.mission)
	return out


## The talk the objective leads to: of the open ones, the highest priority, then the
## nearest to the player. Null when nothing is open.
func objective_talk() -> HubTalk:
	var best: HubTalk = null
	var best_distance: float = INF
	for talk: HubTalk in talks:
		if talk.objective == &"" or _state(talk) != ChapterProgress.MissionState.AVAILABLE:
			continue
		var to: Vector3 = level.marker_position(talk.marker) - player.global_position
		var distance: float = Vector2(to.x, to.z).length()
		if best == null or talk.priority > best.priority:
			best = talk
			best_distance = distance
		elif talk.priority == best.priority and distance < best_distance:
			best = talk
			best_distance = distance
	return best


## Where the objective leads (for the objective marker), or null.
func objective_position() -> Variant:
	var talk: HubTalk = objective_talk()
	if talk == null or player.is_held():
		return null
	return level.marker_position(talk.marker)


## The objective's text now ("Habla con los curacas (1/3)"), or empty.
func objective_text() -> String:
	var talk: HubTalk = objective_talk()
	if talk == null:
		return ""
	var done: int = 0
	var total: int = 0
	for other: HubTalk in talks:
		if other.objective == talk.objective and other.mission != &"":
			total += 1
			done += 1 if progress.is_done(other.mission) else 0
	return tr(talk.objective).format({"count": done, "total": total})


func is_busy() -> bool:
	return _busy


func _update_objective() -> void:
	var text: String = objective_text()
	if text != _objective:
		_objective = text
		objective_changed.emit(text)


func _state(talk: HubTalk) -> ChapterProgress.MissionState:
	if talk.mission == &"":
		return ChapterProgress.MissionState.AVAILABLE
	if progress == null:
		return ChapterProgress.MissionState.LOCKED
	return progress.state(talk.mission)


## 3 open, 2 locked with something to say, 1 done with thanks, 0 nothing to say.
func _rank(talk: HubTalk) -> int:
	match _state(talk):
		ChapterProgress.MissionState.AVAILABLE:
			return 3 if talk.offer != null or talk.mission != &"" else 0
		ChapterProgress.MissionState.DONE:
			return 1 if talk.thanks != null else 0
		ChapterProgress.MissionState.LOCKED:
			return 2 if talk.waiting != null else 0
	return 0


func _markers() -> Array[StringName]:
	var out: Array[StringName] = []
	for talk: HubTalk in talks:
		if not out.has(talk.marker):
			out.append(talk.marker)
	return out


func _play(script: DialogueScript) -> void:
	if script == null or script.lines.is_empty():
		return
	dialogue.play(script)
	await dialogue.dialogue_finished


func _turn_to_player(marker: StringName) -> void:
	for npc: SectorNpc in people:
		if npc.marker == marker:
			npc.face_towards(player.global_position)
