class_name SupportTuning
extends Resource
## The Apoyo of a chapter (F8 task 6, GDD §8.2): its ayllus, and the points at which each
## one moves from Neutral to Sympathizer to Ally.

@export var ayllus: Array[AylluData] = []
@export_range(1, 10, 1) var sympathizer_at: int = 1
@export_range(1, 10, 1) var ally_at: int = 2
## Shown when an ayllu moves up (translation keys).
@export var sympathizer_notice: StringName = &"NOTICE_SUPPORT_SYMPATHIZER"
@export var ally_notice: StringName = &"NOTICE_SUPPORT_ALLY"


func ayllu(id: StringName) -> AylluData:
	for a: AylluData in ayllus:
		if a.id == id:
			return a
	return null
