class_name ChapterData
extends Resource
## A chapter as data (F8 task 4): its missions, in the order the hub lists them.

@export var id: StringName = &""
@export var missions: Array[MissionData] = []
## Its ayllus and the Apoyo thresholds (F8 task 6).
@export var support: SupportTuning
## The level the player comes back to between missions (F8 tasks 7–8; LevelCatalog id).
@export var hub_level: StringName = &"centro"


## The mission with `mission_id`, or null.
func mission(mission_id: StringName) -> MissionData:
	for m: MissionData in missions:
		if m.id == mission_id:
			return m
	return null


## The ids of the missions, in order.
func ids() -> Array[StringName]:
	var out: Array[StringName] = []
	for m: MissionData in missions:
		out.append(m.id)
	return out
