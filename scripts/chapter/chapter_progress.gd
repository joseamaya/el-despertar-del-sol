class_name ChapterProgress
extends RefCounted
## Pure progress through a chapter (F8 task 4, `docs/fases/F8-diseno-tecnico.md`): each
## mission is locked, available, active or done; a mission opens when enough of the ones
## it requires are done ("2 of 3"); a level that ends completes its active mission if the
## mission's flag was set; chapter flags last the whole game. No nodes, so tests need no
## scene. `to_dict()` and `from_dict()` are what the saved game stores (F8 task 5).

signal mission_completed(mission_id: StringName)

enum MissionState { LOCKED, AVAILABLE, ACTIVE, DONE }

const STATE_NAMES: Array[String] = ["locked", "available", "active", "done"]

var chapter: ChapterData
var _done: Array[StringName] = []
var _active: StringName = &""
var _flags: Array[StringName] = []


func _init(data: ChapterData) -> void:
	assert(data != null, "ChapterProgress needs a chapter.")
	chapter = data


func state(mission_id: StringName) -> MissionState:
	var m: MissionData = chapter.mission(mission_id)
	if m == null:
		return MissionState.LOCKED
	if _done.has(mission_id):
		return MissionState.DONE
	if _active == mission_id:
		return MissionState.ACTIVE
	return MissionState.AVAILABLE if _opens(m) else MissionState.LOCKED


## The missions that can be started now, in the chapter's order.
func available() -> Array[StringName]:
	var out: Array[StringName] = []
	for m: MissionData in chapter.missions:
		if state(m.id) == MissionState.AVAILABLE:
			out.append(m.id)
	return out


## Makes an available mission the active one (going into its level). False if it cannot.
func start(mission_id: StringName) -> bool:
	if state(mission_id) != MissionState.AVAILABLE:
		return false
	_active = mission_id
	return true


func active() -> StringName:
	return _active


## Leaves the active mission undone (back to the hub without finishing).
func abandon() -> void:
	_active = &""


## A level ended with `level_flags` set: keeps them as chapter flags and completes the
## active mission if it is played there and its flag (if any) was set. Returns the
## completed mission's id, or empty.
func finish_level(level_id: StringName, level_flags: Array[StringName]) -> StringName:
	for flag: StringName in level_flags:
		set_flag(flag)
	var m: MissionData = chapter.mission(_active)
	if m == null or m.level != level_id:
		return &""
	if m.complete_flag != &"" and not level_flags.has(m.complete_flag):
		return &""
	_active = &""
	_done.append(m.id)
	mission_completed.emit(m.id)
	return m.id


## Marks an open mission done without playing it: the hub's test doors (F8 task 8) and
## missions whose level is not built yet. False if it is not open.
func complete(mission_id: StringName) -> bool:
	var s: MissionState = state(mission_id)
	if s != MissionState.AVAILABLE and s != MissionState.ACTIVE:
		return false
	if _active == mission_id:
		_active = &""
	_done.append(mission_id)
	mission_completed.emit(mission_id)
	return true


func is_done(mission_id: StringName) -> bool:
	return _done.has(mission_id)


func done_count() -> int:
	return _done.size()


func set_flag(flag: StringName) -> void:
	if flag != &"" and not _flags.has(flag):
		_flags.append(flag)


func has_flag(flag: StringName) -> bool:
	return _flags.has(flag)


## What the saved game keeps.
func to_dict() -> Dictionary:
	var missions: Dictionary = {}
	for m: MissionData in chapter.missions:
		missions[String(m.id)] = STATE_NAMES[state(m.id)]
	return {
		"chapter": String(chapter.id),
		"missions": missions,
		"flags": _flags.map(func(f: StringName) -> String: return String(f)),
	}


## Restores what `to_dict()` gave. Unknown missions and states are ignored; a "locked" or
## "available" entry needs nothing (it follows from the done ones).
func from_dict(data: Dictionary) -> void:
	_done.clear()
	_active = &""
	_flags.clear()
	var missions: Dictionary = data.get("missions", {}) as Dictionary
	for key: Variant in missions:
		var mission_id := StringName(str(key))
		if chapter.mission(mission_id) == null:
			continue
		match str(missions[key]):
			"done":
				_done.append(mission_id)
			"active":
				_active = mission_id
	for flag: Variant in data.get("flags", []) as Array:
		set_flag(StringName(str(flag)))


func _opens(m: MissionData) -> bool:
	var count: int = 0
	for required: StringName in m.requires:
		if _done.has(required):
			count += 1
	return count >= m.needed()
