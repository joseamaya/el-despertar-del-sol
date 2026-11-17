class_name InteractionPoint
extends Node
## One thing the player can do at a layout marker (F4 task 4: the huaca; task 6: the
## family). While active it shows its prompt when the player is close enough and emits
## `interacted` when they press `interact` there. Then it switches off.

signal interacted(marker: StringName)

const ACTION_INTERACT: StringName = &"interact"

@export var level: SectorLevel
@export var player: PlayerController
@export var prompt: InteractionPrompt
## Optional: no prompt while someone speaks.
@export var dialogue: DialoguePlayer

var _marker: StringName = &""
var _radius: float = 0.0
var _prompt_key: StringName = &""


func _ready() -> void:
	assert(level != null and player != null and prompt != null, "InteractionPoint: parts.")


func _physics_process(_delta: float) -> void:
	if not is_active():
		return
	if is_in_reach() and not _busy():
		prompt.show_prompt(_prompt_key)
	else:
		prompt.hide_prompt()


func _unhandled_input(event: InputEvent) -> void:
	if is_active() and event.is_action_pressed(ACTION_INTERACT):
		try_interact()


## Waits for the player at `marker`, within `radius` metres on the ground plane.
func activate(marker: StringName, radius: float, prompt_key: StringName) -> void:
	_marker = marker
	_radius = radius
	_prompt_key = prompt_key


func deactivate() -> void:
	_marker = &""
	prompt.hide_prompt()


func is_active() -> bool:
	return _marker != &""


func is_in_reach() -> bool:
	if not is_active():
		return false
	var to: Vector3 = level.marker_position(_marker) - player.global_position
	return Vector2(to.x, to.z).length() <= _radius


## Interacts if possible (the input handler and tests call this). True if it happened.
func try_interact() -> bool:
	if not is_in_reach() or _busy():
		return false
	var marker: StringName = _marker
	deactivate()
	get_viewport().set_input_as_handled()
	interacted.emit(marker)
	return true


func _busy() -> bool:
	return dialogue != null and dialogue.is_playing()
