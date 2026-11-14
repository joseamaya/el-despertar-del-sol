class_name HitDefense
extends Node
## Base for anything that decides whether a hit lands on a Hurtbox (player block/parry/
## dodge, an enemy's guard, a future shield). Override resolve_hit().


## Outcome of an incoming hit; apply side effects (stamina, posture) here.
func resolve_hit(_info: HitInfo) -> DefenseRules.Outcome:
	return DefenseRules.Outcome.HIT
