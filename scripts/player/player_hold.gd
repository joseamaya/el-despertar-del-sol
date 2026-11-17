class_name PlayerHold
extends RefCounted
## Holds the player still and out of combat while something plays (dialogue, rites) and
## lets go after (F4 tasks 3–4). The camera keeps turning.


static func set_held(player: PlayerController, frozen: Array[Node], held: bool) -> void:
	player.set_speed_limit(0.0 if held else -1.0)
	for node: Node in frozen:
		node.set_physics_process(not held)
		node.set_process(not held)
