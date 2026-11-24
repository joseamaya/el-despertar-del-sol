class_name SupportLedger
extends RefCounted
## Pure Apoyo per ayllu (F8 task 6, GDD §8.2): points per ayllu, and from them its state,
## Neutral → Sympathizer → Ally, and the chapter's total. A mission done raises its ayllu
## (or every ayllu already won, for the show of force), if its support flag was set.
## `to_dict()`/`from_dict()` are what the saved game keeps. No nodes.

## `ayllu_id` moved to `level` (only when it goes up a state).
signal level_raised(ayllu_id: StringName, level: Level)

enum Level { NEUTRAL, SYMPATHIZER, ALLY }

var tuning: SupportTuning
var _points: Dictionary[StringName, int] = {}


func _init(support: SupportTuning) -> void:
	assert(support != null, "SupportLedger needs its tuning.")
	tuning = support


func points(ayllu_id: StringName) -> int:
	return _points.get(ayllu_id, 0)


func level(ayllu_id: StringName) -> Level:
	var p: int = points(ayllu_id)
	if p >= tuning.ally_at:
		return Level.ALLY
	if p >= tuning.sympathizer_at:
		return Level.SYMPATHIZER
	return Level.NEUTRAL


## The chapter's Apoyo: every point won.
func total() -> int:
	var sum: int = 0
	for p: int in _points.values():
		sum += p
	return sum


## Adds `amount` points to a known ayllu. Returns its new level.
func gain(ayllu_id: StringName, amount: int = 1) -> Level:
	if tuning.ayllu(ayllu_id) == null or amount <= 0:
		return level(ayllu_id)
	var before: Level = level(ayllu_id)
	_points[ayllu_id] = points(ayllu_id) + amount
	var after: Level = level(ayllu_id)
	if after > before:
		level_raised.emit(ayllu_id, after)
	return after


## A mission was done with `flags` set: raises what it wins, if its support flag (when it
## has one) is among them. Returns the ayllus raised.
func apply_mission(mission: MissionData, flags: Array[StringName]) -> Array[StringName]:
	var raised: Array[StringName] = []
	if mission.support_flag != &"" and not flags.has(mission.support_flag):
		return raised
	if mission.support_all_won:
		for a: AylluData in tuning.ayllus:
			if level(a.id) != Level.NEUTRAL:
				gain(a.id, mission.support_gain)
				raised.append(a.id)
	elif mission.ayllu != &"":
		gain(mission.ayllu, mission.support_gain)
		raised.append(mission.ayllu)
	return raised


func to_dict() -> Dictionary:
	var out: Dictionary = {}
	for id: StringName in _points:
		out[String(id)] = _points[id]
	return out


## Restores what `to_dict()` gave; unknown ayllus are ignored.
func from_dict(data: Dictionary) -> void:
	_points.clear()
	for key: Variant in data:
		var id := StringName(str(key))
		if tuning.ayllu(id) != null:
			_points[id] = maxi(0, int(data[key]))
