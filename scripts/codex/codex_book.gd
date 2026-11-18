class_name CodexBook
extends Resource
## Every codex entry the game has, in reading order (GDD §12.6).

@export var entries: Array[CodexEntry] = []


## The entry with this id, or null.
func find(id: StringName) -> CodexEntry:
	for entry: CodexEntry in entries:
		if entry.id == id:
			return entry
	return null
