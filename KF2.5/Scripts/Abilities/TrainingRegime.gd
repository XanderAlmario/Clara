extends Node

func trigger_ability(deck_ref, battle_manager) -> bool:
	var targets = battle_manager.playerUnitsOnBF
	
	if targets.size() == 0:
		return false
	
	for unit in targets:
		if unit:
			unit.attack += 2
			unit.health += 2
			
			if unit.has_node("Attack"):
				unit.get_node("Attack").text = str(unit.attack)
			if unit.has_node("Health"):
				unit.get_node("Health").text = str(unit.health)
	
	print("Training Regime complete: All units granted +2/+2.")
	return true
