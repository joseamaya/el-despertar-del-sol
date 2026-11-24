class_name Codex
extends Node
## Which codex entries the player has unlocked (F4 task 5, GDD §12.6). Lives in the
## level; the saved game keeps them (F8 task 5).

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


## Unlocks entries from a saved game without announcing them (F8 task 5). Unknown ids
## are ignored.
func restore(ids: Array[StringName]) -> void:
	for id: StringName in ids:
		if book.find(id) != null and not is_unlocked(id):
			_unlocked.append(id)


## The ids unlocked so far, for the saved game.
func unlocked_ids() -> Array[StringName]:
	return _unlocked.duplicate()


func is_unlocked(id: StringName) -> bool:
	return _unlocked.has(id)


## Unlocked entries in book order.
func unlocked_entries() -> Array[CodexEntry]:
	var out: Array[CodexEntry] = []
	for entry: CodexEntry in book.entries:
		if is_unlocked(entry.id):
			out.append(entry)
	return out
