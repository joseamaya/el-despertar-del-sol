class_name MissionData
extends Resource
## One mission of a chapter (F8 task 4, `docs/capitulo-1.md` §3): where it is played, which
## ayllu it wins over, and which missions open it. "2 of 3" is `requires` with
## `requires_count` = 2.

@export var id: StringName = &""
## Shown in the hub and the pause menu (translation key).
@export var title: StringName = &""
## The level it is played in (LevelCatalog id).
@export var level: StringName = &""
## The ayllu whose Apoyo it raises (F8 task 6). Empty: none.
@export var ayllu: StringName = &""
## Missions that open this one.
@export var requires: Array[StringName] = []
## How many of `requires` must be done. 0: all of them.
@export_range(0, 10, 1) var requires_count: int = 0
## Level flag that marks it done when the level ends. Empty: ending the level is enough.
@export var complete_flag: StringName = &""
## Hub marker where Cusi comes back after it, done or left (F10 task 3: next to whoever
## gave it). Empty: the hub's start.
@export var hub_return: StringName = &""

@export_group("Apoyo")
## Points of Apoyo it gives its ayllu when done (F8 task 6).
@export_range(0, 5, 1) var support_gain: int = 1
## The Apoyo comes only if this level flag was set (Carmenca: the llamas freed). Empty:
## always.
@export var support_flag: StringName = &""
## Gives the points to every ayllu already won instead (the show of force).
@export var support_all_won: bool = false


## How many of `requires` have to be done for it to open.
func needed() -> int:
	return requires.size() if requires_count <= 0 else mini(requires_count, requires.size())
