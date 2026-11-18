class_name DialogueChoice
extends Resource
## A choice the player makes in a conversation (F4 task 6): who answers and the options,
## in the order shown.

@export var speaker: StringName = &""
@export var options: Array[DialogueOption] = []
