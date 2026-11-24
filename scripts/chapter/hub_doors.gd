class_name HubDoors
extends Node
## The hub's mission doors (F8 task 8, `docs/capitulo-1.md` §3): each open mission of the
## chapter has a marker "Door_<mission id>" in the hub layout. Near one, the prompt names
## the mission; pressing interact asks to play it. Doors of missions that are locked or
## done do nothing. The chapter's progress comes from the game shell (LevelEntry).

signal mission_chosen(mission_id: StringName)

const ACTION_INTERACT: StringName = &"interact"
const PREFIX: String = "Door_"

@export var level: SectorLevel
@export var player: PlayerController
@export var prompt: InteractionPrompt
@export_range(0.5, 10.0, 0.5, "suffix:m") var radius: float = 3.0

## Set by LevelEntry inside the game shell. Null: no door is open.
var progress: ChapterProgress
var _near: StringName = &""


func _ready() -> void:
	assert(level != null and player != null and prompt != null, "HubDoors: parts.")


func _physics_process(_delta: float) -> void:
	var door: StringName = nearest_open_door()
	if door == _near:
		return
	_near = door
	if door == &"":
		prompt.hide_prompt()
	else:
		var title: StringName = progress.chapter.mission(door).title
		prompt.show_text(tr(&"DOOR_PROMPT").format({"mission": tr(title)}))


func _unhandled_input(event: InputEvent) -> void:
	if _near != &"" and event.is_action_pressed(ACTION_INTERACT):
		get_viewport().set_input_as_handled()
		choose(_near)


## Asks to play an open mission (the player's button; tests).
func choose(mission_id: StringName) -> bool:
	if progress == null or progress.state(mission_id) != ChapterProgress.MissionState.AVAILABLE:
		return false
	mission_chosen.emit(mission_id)
	return true


## The open mission whose door the player is at, or empty.
func nearest_open_door() -> StringName:
	if progress == null:
		return &""
	var best: StringName = &""
	var best_distance: float = radius
	for mission_id: StringName in progress.available():
		var marker: StringName = StringName(PREFIX + String(mission_id))
		if not level.layout.points.has(marker):
			continue
		var to: Vector3 = level.marker_position(marker) - player.global_position
		var distance: float = Vector2(to.x, to.z).length()
		if distance <= best_distance:
			best = mission_id
			best_distance = distance
	return best


## Doors of the open missions, for tests and the objective marker.
func open_doors() -> Array[StringName]:
	var out: Array[StringName] = []
	if progress == null:
		return out
	for mission_id: StringName in progress.available():
		if level.layout.points.has(StringName(PREFIX + String(mission_id))):
			out.append(mission_id)
	return out
