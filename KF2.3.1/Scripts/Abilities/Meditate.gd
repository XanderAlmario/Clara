extends Node

func trigger_ability(deck_ref, battle_manager) -> bool:
	var targets = battle_manager.playerUnitsOnBF
	
	if targets.size() > 0:
		var random_unit = targets.pick_random()
		random_unit.health += 2
		if random_unit.has_node("Health"):
			random_unit.get_node("Health").text = str(random_unit.health)
	if deck_ref and deck_ref.player_deck.size() > 0:
		var card_to_draw = deck_ref.player_deck[0]
		deck_ref.drawCard(card_to_draw)
		
	return true
