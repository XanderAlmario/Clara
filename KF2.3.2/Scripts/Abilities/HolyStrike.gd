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
				
		generate_bottle_of_devotion(battle_manager)
	return true

func generate_bottle_of_devotion(battle_manager):
	var deck_ref = battle_manager.get_node("../Deck")
	var hand_ref = battle_manager.get_node("../PlayerHand")
	var card_manager_ref = battle_manager.get_node("../CardManager")
	
	if deck_ref and hand_ref and card_manager_ref:
		var card_name = "Bottle of Devotion"
		var card_scene = preload("res://Scenes/Card.tscn")
		var new_card = card_scene.instantiate()
		var card_data = deck_ref.cardDBRef.CARDS[card_name]
		
		new_card.get_node("CardImage").texture = load("res://Assets/" + card_name + ".png")
		new_card.cost = card_data[0]
		new_card.cardType = str(card_data[3])
		new_card.get_node("Cost").text = str(new_card.cost)
		new_card.get_node("Ability").text = str(card_data[4])
		new_card.get_node("Attack").visible = false
		new_card.get_node("Health").visible = false
		
		if card_data.size() > 15 and card_data[15] != null:
			var script_res = load(card_data[15])
			if script_res:
				new_card.spellScript = script_res.new()
			else:
				new_card.spellScript = null
		card_manager_ref.add_child(new_card)
		new_card.name = "Card"
		hand_ref.addCardToHand(new_card, 0.5) 
		new_card.get_node("AnimationPlayer").play("cardFlip")
