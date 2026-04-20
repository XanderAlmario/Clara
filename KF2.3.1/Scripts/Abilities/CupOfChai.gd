extends Node

func trigger_ability(deck_ref, battle_manager) -> bool:
	var targets = battle_manager.playerUnitsOnBF
	
	if targets.size() > 0:
		var random_unit = targets.pick_random()
		random_unit.health += 2
		
		if random_unit.has_node("Health"):
			random_unit.get_node("Health").text = str(random_unit.health)
		return true
	
	return false
