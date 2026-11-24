class_name LevelCatalog
extends Resource
## The levels the game shell can load, by id (F8 task 3): carmenca, and later the prologue,
## the hub and the missions (`docs/capitulo-1.md`).

@export var levels: Dictionary[StringName, String] = {}
## The level a new game starts in.
@export var first_level: StringName = &""


func has_level(id: StringName) -> bool:
	return levels.has(id)


## The scene path of `id`; empty if unknown.
func path_of(id: StringName) -> String:
	return levels.get(id, "") as String
