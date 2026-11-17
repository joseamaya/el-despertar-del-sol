class_name DialoguePlayer
extends Node
## Plays a DialogueScript line by line (F4 task 3): the player stands still and cannot
## fight while it lasts (the camera still turns), and `interact` moves to the next line.

signal line_shown(index: int)
signal dialogue_finished

const ACTION_NEXT: StringName = &"interact"

@export var box: DialogueBox
@export var player: PlayerController
## Nodes that read combat input (Combat, Defense…): paused while someone speaks.
@export var frozen: Array[Node] = []

var _script: DialogueScript
var _index: int = -1


func _ready() -> void:
	assert(box != null and player != null, "DialoguePlayer: parts.")


func _unhandled_input(event: InputEvent) -> void:
	if is_playing() and event.is_action_pressed(ACTION_NEXT):
		get_viewport().set_input_as_handled()
		advance()


func play(dialogue: DialogueScript) -> void:
	assert(dialogue != null and not dialogue.lines.is_empty(), "DialoguePlayer: empty.")
	_script = dialogue
	_index = -1
	_set_controls(false)
	advance()


## Next line, or the end of the conversation after the last one.
func advance() -> void:
	if not is_playing():
		return
	_index += 1
	if _index >= _script.lines.size():
		_finish()
		return
	var line: DialogueLine = _script.lines[_index]
	box.show_line(line.speaker, line.text)
	line_shown.emit(_index)


func is_playing() -> bool:
	return _script != null


func _finish() -> void:
	_script = null
	_index = -1
	box.hide_line()
	_set_controls(true)
	dialogue_finished.emit()


func _set_controls(enabled: bool) -> void:
	PlayerHold.set_held(player, frozen, not enabled)
