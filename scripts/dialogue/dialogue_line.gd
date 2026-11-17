class_name DialogueLine
extends Resource
## One line of dialogue (F4 task 3): who speaks and what, both as translation keys
## (localization/ui.csv), so every visible text goes through tr().

@export var speaker: StringName = &""
@export var text: StringName = &""
