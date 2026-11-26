class_name HubTalk
extends Resource
## What someone in the hub says about one mission (F9 task 6, `docs/fases/F9-diseno-centro.md`
## §3): who stands where, the lines that offer it, what they say while it is still locked
## and once it is done, and the objective that leads Cusi to them.

## Layout marker where they stand (a SectorNpc on the same marker turns to Cusi).
@export var marker: StringName = &""
## Their name in the prompt (translation key).
@export var speaker: StringName = &""
## The mission they offer. Empty: they only talk (`offer` is then all they say).
@export var mission: StringName = &""
## Before the question "will you help?": the problem, in 2–3 lines.
@export var offer: DialogueScript
## While the mission is still locked. Null: nothing to say yet.
@export var waiting: DialogueScript
## Once the mission is done.
@export var thanks: DialogueScript
## The objective while the mission is open: a translation key with {count} and {total}
## (how many talks with the same key are done, and how many there are).
@export var objective: StringName = &""
## Higher goes first when several objectives are open (Vicaquirao before the curacas).
@export_range(0, 10, 1) var priority: int = 0
