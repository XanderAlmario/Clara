extends Node

func trigger_targeted_ability(target, battle_manager, is_player) -> bool:
	if target and target.get("cardType") == "Unit":
		var player_battlefield = battle_manager.get_node("../PlayerBattlefield")
		var player_card_manager = battle_manager.get_node("../CardManager")

		if player_battlefield.unitsInPlay.size() >= player_battlefield.BFSize:
			print("Your battlefield is full!")
			return false

		var copy = target.duplicate()
		copy.name = target.name + "_Projection_" + str(randi())
		
		var area = copy.find_child("Area2D", true, false)
		if area:
			area.collision_layer = 1
			area.collision_mask = 1
		
		player_card_manager.add_child(copy)
		player_battlefield.unitsInPlay.append(copy)
		copy.cardSlot = player_battlefield
		player_card_manager.updateCardsOnBF(player_battlefield)
		return true
		
	return false
