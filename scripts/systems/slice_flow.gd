class_name SliceFlow
extends RefCounted
## Pure progress through a SliceSequence (F4 task 2): which step is current, which act,
## which checkpoint holds, when it is over. No nodes, so tests need no scene.

var _steps: Array[SliceStep]
var _index: int = 0


func _init(sequence: SliceSequence) -> void:
	_steps = sequence.steps


## The step being played; null once the slice is over.
func current() -> SliceStep:
	return _steps[_index] if _index < _steps.size() else null


func index() -> int:
	return _index


func is_finished() -> bool:
	return _index >= _steps.size()


## Completes the current step. Returns the next one, or null if the slice is over.
func advance() -> SliceStep:
	if not is_finished():
		_index += 1
	return current()


## The act of the current step (the last act once finished).
func act() -> SliceStep.Act:
	if _steps.is_empty():
		return SliceStep.Act.OPENING
	return _steps[mini(_index, _steps.size() - 1)].act


## The respawn marker in force: the latest checkpoint of the steps started so far.
func checkpoint() -> StringName:
	for i: int in range(mini(_index, _steps.size() - 1), -1, -1):
		if _steps[i].checkpoint != &"":
			return _steps[i].checkpoint
	return &""
