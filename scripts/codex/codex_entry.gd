class_name CodexEntry
extends Resource
## One codex entry (GDD §3.1, §12.6): a person, place, object or belief, with the label
## that says how much of it is history. Every text is a translation key.

enum Tag { DOCUMENTED, CHRONICLERS, LICENCE }

## Translation key of each Tag, in order.
const TAG_KEYS: Array[StringName] = [
	&"CODEX_TAG_DOCUMENTED",
	&"CODEX_TAG_CHRONICLERS",
	&"CODEX_TAG_LICENCE",
]

@export var id: StringName = &""
@export var title: StringName = &""
@export var tag: Tag = Tag.CHRONICLERS
## Who says it (author and work); empty when the entry has no single source.
@export var source: StringName = &""
@export var body: StringName = &""
## Optional closing note, e.g. what in the game is licence.
@export var note: StringName = &""


func tag_key() -> StringName:
	return TAG_KEYS[tag]
