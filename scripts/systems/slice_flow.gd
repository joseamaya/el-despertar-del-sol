class_name SliceFlow
extends RefCounted
## Pure progress through a SliceSequence (F4 tasks 2 and 6): which step is current, which
## act, which checkpoint holds, which flags the player's choices have set, when it is
## over. Steps whose condition does not hold are skipped. No nodes, so tests need no scene.

var _steps: Array[SliceStep]
var _index: int = 0
var _flags: Array[StringName] = []
var _checkpoint: StringName = &""


func _init(sequence: SliceSequence) -> void:
	_steps = sequence.steps
	_settle()


## The step being played; null once the slice is over.
func current() -> SliceStep:
	return _steps[_index] if _index < _steps.size() else null


func index() -> int:
	return _index


func is_finished() -> bool:
	return _index >= _steps.size()


## Completes the current step: sets its flag and `extra_flag` (a choice's), then moves to
## the next step that applies. Returns it, or null if the slice is over.
func advance(extra_flag: StringName = &"") -> SliceStep:
	if not is_finished():
		set_flag(_steps[_index].flag)
		set_flag(extra_flag)
		_index += 1
		_settle()
	return current()


## The step that would follow the current one with the flags set so far (null if none).
func peek_next() -> SliceStep:
	for i: int in range(_index + 1, _steps.size()):
		if applies(_steps[i]):
			return _steps[i]
	return null


## While the current step is optional: the first required step after it that applies
## (null if none, or if the current step is required).
func next_required() -> SliceStep:
	if is_finished() or not _steps[_index].optional:
		return null
	for i: int in range(_index + 1, _steps.size()):
		if applies(_steps[i]) and not _steps[i].optional:
			return _steps[i]
	return null


## Leaves the optional steps from the current one on undone (no flags). Returns the
## step reached.
func skip_optional() -> SliceStep:
	while not is_finished() and _steps[_index].optional:
		_index += 1
		_settle()
	return current()


## Sets `flag` and moves past the steps it turns off, from the current one (skipping the
## opening). Returns the step reached.
func skip_with(flag: StringName) -> SliceStep:
	set_flag(flag)
	_settle()
	return current()


func set_flag(flag: StringName) -> void:
	if flag != &"" and not _flags.has(flag):
		_flags.append(flag)


func has_flag(flag: StringName) -> bool:
	return _flags.has(flag)


## Whether a step's condition holds with the flags set so far.
func applies(step: SliceStep) -> bool:
	if step.only_if != &"" and not has_flag(step.only_if):
		return false
	return step.unless == &"" or not has_flag(step.unless)


## The act of the current step (the last act once finished).
func act() -> SliceStep.Act:
	if _steps.is_empty():
		return SliceStep.Act.OPENING
	return _steps[mini(_index, _steps.size() - 1)].act


## The respawn marker in force: the latest checkpoint of the steps started so far.
func checkpoint() -> StringName:
	return _checkpoint


func _settle() -> void:
	while _index < _steps.size() and not applies(_steps[_index]):
		_index += 1
	if _index < _steps.size() and _steps[_index].checkpoint != &"":
		_checkpoint = _steps[_index].checkpoint
