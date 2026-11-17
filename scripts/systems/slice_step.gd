class_name SliceStep
extends Resource
## One step of the vertical slice (F4 task 2, GDD §14.1): reach a place, clear an
## encounter zone, wait a moment or hold a conversation (task 3). Steps run one after another; see SliceFlow.

enum Act { OPENING, EXPLORATION, SUPPORT, COMBAT, ENDING }
enum Kind { REACH, ENCOUNTER, WAIT, DIALOGUE }

@export var act: Act = Act.OPENING
@export var kind: Kind = Kind.REACH
## REACH: the layout marker to get to (Huaca, Family, Ending…).
@export var marker: StringName = &""
## REACH: how close counts as arrived, on the ground plane.
@export_range(0.5, 30.0, 0.5, "suffix:m") var radius: float = 4.0
## ENCOUNTER: the zone to clear (1-based, as Encounter1…).
@export_range(0, 10, 1) var zone: int = 0
## WAIT: how long. A placeholder for dialogue and scenes until their tasks land.
@export_range(0.0, 60.0, 0.5, "suffix:s") var seconds: float = 0.0
## DIALOGUE: the conversation; the step ends with it.
@export var dialogue: DialogueScript
## Respawn marker from the moment this step starts (empty: keep the previous one).
@export var checkpoint: StringName = &""
