extends Node

func trigger_ability(_deck_manager, battle_manager):
	var enemies = battle_manager.enemyUnitsOnBF
	
	if enemies.size() > 0:
		var target = enemies[randi() % enemies.size()]
		if target:
			var damage = 2
			target.health -= damage
			target.get_node("Health").text = str(target.health)
			
			if target.health <= 0:
				battle_manager.destroyCard(target, "enemy")
