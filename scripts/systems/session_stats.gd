class_name SessionStats
extends RefCounted
## What happened in one playthrough of the slice, for the external test (F5 task 3,
## DECISIONS/0013): time per act, defeats per zone and a few choices. Only facts about the
## game, nothing about the person. Pure: SessionSummary feeds it and shows its text.

## Seconds spent in each SliceStep.Act, in order.
var act_seconds: PackedFloat32Array = PackedFloat32Array([0.0, 0.0, 0.0, 0.0, 0.0])
## Defeats in each encounter zone (index 0 is zone 1).
var defeats: PackedInt32Array = PackedInt32Array()
var helped_ayllu: bool = false
var made_offering: bool = false
var opened_codex: bool = false
var did_tutorial: bool = false
var used_gamepad: bool = false


func add_act_time(act: int, seconds: float) -> void:
	if act >= 0 and act < act_seconds.size():
		act_seconds[act] += maxf(0.0, seconds)


## `zone` is 1-based, as ArenaController numbers them.
func add_defeat(zone: int) -> void:
	if zone < 1:
		return
	while defeats.size() < zone:
		defeats.append(0)
	defeats[zone - 1] += 1


func total_seconds() -> float:
	var total: float = 0.0
	for s: float in act_seconds:
		total += s
	return total


## "m:ss".
static func clock(seconds: float) -> String:
	var whole: int = roundi(seconds)
	return "%d:%02d" % [floori(whole / 60.0), whole % 60]


## The summary to paste into the survey. `act_keys` and `zone_keys` are translation keys
## (one per act, one per zone); `version` is the game's version.
func render(version: String, act_keys: Array[StringName], zone_keys: Array[StringName]) -> String:
	var acts: PackedStringArray = PackedStringArray()
	for i: int in act_seconds.size():
		var key: StringName = act_keys[i] if i < act_keys.size() else &""
		acts.append("%s %s" % [_tr(key), clock(act_seconds[i])])
	var zones: PackedStringArray = PackedStringArray()
	for i: int in zone_keys.size():
		zones.append("%s %d" % [_tr(zone_keys[i]), defeats[i] if i < defeats.size() else 0])
	var lines: PackedStringArray = PackedStringArray()
	lines.append(_tr(&"SUMMARY_TITLE").format({"version": version}))
	lines.append(
		_tr(&"SUMMARY_TIME").format({"total": clock(total_seconds()), "acts": " · ".join(acts)})
	)
	lines.append(_tr(&"SUMMARY_DEFEATS").format({"zones": " · ".join(zones)}))
	var ayllu: StringName = &"SUMMARY_HELPED" if helped_ayllu else &"SUMMARY_PASSED_BY"
	var choices: Dictionary = {
		"ayllu": _tr(ayllu),
		"offering": _yes_no(made_offering),
		"codex": _yes_no(opened_codex),
		"tutorial": _yes_no(did_tutorial),
		"gamepad": _yes_no(used_gamepad),
	}
	lines.append(_tr(&"SUMMARY_CHOICES").format(choices))
	return "\n".join(lines)


static func _yes_no(value: bool) -> String:
	return _tr(&"SUMMARY_YES" if value else &"SUMMARY_NO")


static func _tr(key: StringName) -> String:
	return String(TranslationServer.translate(key))
