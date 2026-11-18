class_name SliceStep
extends Resource
## One step of the vertical slice (F4 task 2, GDD §14.1): reach a place, clear an
## encounter zone, wait a moment, hold a conversation (task 3), or do something at a
## marker and play a huaca rite there (task 4), or choose (task 6). Steps run one after
## another; a step can depend on a flag set by an earlier one. See SliceFlow.

enum Act { OPENING, EXPLORATION, SUPPORT, COMBAT, ENDING }
enum Kind { REACH, ENCOUNTER, WAIT, DIALOGUE, INTERACT, RITE, CHOICE }

@export var act: Act = Act.OPENING
@export var kind: Kind = Kind.REACH
## REACH, INTERACT, RITE: the layout marker (Huaca, Family, Ending…).
@export var marker: StringName = &""
## REACH, INTERACT: how close counts as there, on the ground plane.
@export_range(0.5, 30.0, 0.5, "suffix:m") var radius: float = 4.0
## ENCOUNTER: the zone to clear (1-based, as Encounter1…).
@export_range(0, 10, 1) var zone: int = 0
## WAIT: how long. A placeholder for dialogue and scenes until their tasks land.
@export_range(0.0, 60.0, 0.5, "suffix:s") var seconds: float = 0.0
## INTERACT: the prompt shown when close (translation key).
@export var prompt: StringName = &""
## DIALOGUE: the conversation; the step ends with it.
@export var dialogue: DialogueScript
## CHOICE: the options; the one picked sets its flag.
@export var choice: DialogueChoice
## What the player has to do now, shown by the HUD (translation key; ENCOUNTER texts take
## {count}, the warriors left). Empty: no objective (conversations, the vision).
@export var objective: StringName = &""
## Respawn marker from the moment this step starts (empty: keep the previous one).
@export var checkpoint: StringName = &""

@export_group("Flags")
## The player may pass it by (the huaca): reaching the next required REACH step while
## this one waits for them skips it, without setting its flag.
@export var optional: bool = false
## Set when the step completes (e.g. the llamas freed).
@export var flag: StringName = &""
## Played only if this flag is set / only if it is not. Empty: no condition.
@export var only_if: StringName = &""
@export var unless: StringName = &""
## Shown as a banner when the step completes (translation key).
@export var notice: StringName = &""
