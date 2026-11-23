class_name PlayerHold
extends RefCounted
## Holds the player still and out of combat while something plays (dialogue, rites) and
## lets go after (F4 tasks 3–4). The camera keeps turning.


static func set_held(player: PlayerController, frozen: Array[Node], held: bool) -> void:
	if held:
		_interrupt(player, frozen)
	player.set_speed_limit(0.0 if held else -1.0)
	for node: Node in frozen:
		node.set_physics_process(not held)
		node.set_process(not held)


## Ends whatever the player was doing (F6 bug): a dodge or an attack frozen halfway kept
## its velocity, and the player slid on out of control until a wall stopped them.
static func _interrupt(player: PlayerController, frozen: Array[Node]) -> void:
	for node: Node in frozen:
		if node is DefenseComponent:
			(node as DefenseComponent).interrupt()
		elif node is CombatComponent:
			(node as CombatComponent).cancel()
	player.end_action()
	player.velocity.x = 0.0
	player.velocity.z = 0.0
