class_name Codex
extends Node
## Which codex entries the player has unlocked (F4 task 5, GDD §12.6). Lives in the
## level: unlocks last until the scene reloads (saving comes later).

signal entry_unlocked(entry: CodexEntry)

@export var book: CodexBook

var _unlocked: Array[StringName] = []


func _ready() -> void:
	assert(book != null, "Codex: book.")


## Unlocks an entry of the book. True if it was locked until now.
func unlock(id: StringName) -> bool:
	var entry: CodexEntry = book.find(id)
	assert(entry != null, "Codex: no entry '%s'." % id)
	if entry == null or is_unlocked(id):
		return false
	_unlocked.append(id)
	entry_unlocked.emit(entry)
	return true


func is_unlocked(id: StringName) -> bool:
	return _unlocked.has(id)


## Unlocked entries in book order.
func unlocked_entries() -> Array[CodexEntry]:
	var out: Array[CodexEntry] = []
	for entry: CodexEntry in book.entries:
		if is_unlocked(entry.id):
			out.append(entry)
	return out
