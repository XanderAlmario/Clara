extends Node

func trigger_ability(_deck_manager, battle_manager) -> bool:
	var enemies = battle_manager.enemyUnitsOnBF
	if enemies.size() == 0:
		return false
		
	var target = enemies[randi() % enemies.size()]
	var damage = 2
	if "health" in target:
		target.health -= damage
		if target.has_node("Health"):
			target.get_node("Health").text = str(target.health)
		
		if target.health <= 0:
			battle_manager.destroyCard(target, "enemy")
			
	return true 
