class_name SessionSummary
extends Node
## Keeps the playthrough summary for the external test (F5 task 3, DECISIONS/0013) from
## the signals of the slice, the arena, the huaca and the codex, and whether a gamepad is
## used. At the end it saves it to `user://` and copies it to the clipboard on request
## (`copy_summary`), so the tester can paste it into the survey. Nothing leaves the machine
## and nothing identifies the player.

signal summary_copied

const ACTION_COPY: StringName = &"copy_summary"
const FILE_PATH: String = "user://resumen_partida.txt"
## A stick pushed this far counts as using the gamepad.
const STICK_USED: float = 0.5
## Short name of each SliceStep.Act, in order.
const ACT_KEYS: Array[StringName] = [
	&"SUMMARY_ACT_OPENING",
	&"SUMMARY_ACT_EXPLORATION",
	&"SUMMARY_ACT_SUPPORT",
	&"SUMMARY_ACT_COMBAT",
	&"SUMMARY_ACT_ENDING",
]

@export var slice: SliceDirector
@export var arena: ArenaController
## Optional: the offering at the huaca.
@export var rite: HuacaRite
## Optional: whether the codex was opened.
@export var codex_screen: CodexScreen
## Short name of each encounter zone (translation keys), in order.
@export var zone_keys: Array[StringName] = []
## Slice flags read at the end.
@export var ayllu_flag: StringName = &"help_family"
@export var skip_training_flag: StringName = &"skip_training"

var stats := SessionStats.new()
var _act: int = -1
var _act_started: float = 0.0
var _finished: bool = false


func _ready() -> void:
	assert(slice != null and arena != null, "SessionSummary: slice and arena.")
	slice.act_changed.connect(_on_act_changed)
	slice.slice_finished.connect(_on_finished)
	arena.player_defeated.connect(func() -> void: stats.add_defeat(arena.active_zone))
	if rite != null:
		rite.offering_made.connect(func(_m: StringName) -> void: stats.made_offering = true)
	if codex_screen != null:
		codex_screen.opened.connect(func() -> void: stats.opened_codex = true)


func _input(event: InputEvent) -> void:
	if stats.used_gamepad:
		return
	if event is InputEventJoypadButton and (event as InputEventJoypadButton).pressed:
		stats.used_gamepad = true
	elif event is InputEventJoypadMotion:
		stats.used_gamepad = absf((event as InputEventJoypadMotion).axis_value) >= STICK_USED


func _unhandled_input(event: InputEvent) -> void:
	if _finished and event.is_action_pressed(ACTION_COPY):
		copy()
		get_viewport().set_input_as_handled()


func is_finished() -> bool:
	return _finished


## The summary as it stands (the current act counts up to now).
func text() -> String:
	var snapshot: SessionStats = _snapshot()
	return snapshot.render(_version(), ACT_KEYS, zone_keys)


func copy() -> void:
	DisplayServer.clipboard_set(text())
	summary_copied.emit()


func _on_act_changed(act: SliceStep.Act) -> void:
	_close_act()
	_act = act
	_act_started = slice.play_time


func _on_finished() -> void:
	_close_act()
	_act = -1
	stats.helped_ayllu = slice.has_flag(ayllu_flag)
	stats.did_tutorial = not slice.has_flag(skip_training_flag)
	_finished = true
	var file := FileAccess.open(FILE_PATH, FileAccess.WRITE)
	if file != null:
		file.store_string(text() + "\n")


func _close_act() -> void:
	if _act >= 0:
		stats.add_act_time(_act, slice.play_time - _act_started)
		_act_started = slice.play_time


## The stats with the act being played counted up to now, without closing it.
func _snapshot() -> SessionStats:
	var copy_stats := SessionStats.new()
	copy_stats.act_seconds = stats.act_seconds.duplicate()
	copy_stats.defeats = stats.defeats.duplicate()
	copy_stats.helped_ayllu = stats.helped_ayllu or slice.has_flag(ayllu_flag)
	copy_stats.made_offering = stats.made_offering
	copy_stats.opened_codex = stats.opened_codex
	copy_stats.did_tutorial = stats.did_tutorial or not slice.has_flag(skip_training_flag)
	copy_stats.used_gamepad = stats.used_gamepad
	if _act >= 0:
		copy_stats.add_act_time(_act, slice.play_time - _act_started)
	return copy_stats


func _version() -> String:
	var version: String = str(ProjectSettings.get_setting("application/config/version", ""))
	return version if version != "" else "dev"
