extends Node

func trigger_targeted_ability(target, battle_manager) -> bool:
	var damage = 2
	
	if "health" in target:
		target.health -= damage
		if target.has_node("Health"):
			target.get_node("Health").text = str(target.health)
		
		if target.health <= 0:
			battle_manager.destroyCard(target, "Enemy") 
			if battle_manager.enemyBF and target in battle_manager.enemyBF.unitsInPlay:
				battle_manager.enemyBF.unitsInPlay.erase(target)
				battle_manager.updateCardsOnBF(battle_manager.enemyBF)
			
	return true
