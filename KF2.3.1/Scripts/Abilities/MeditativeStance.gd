extends Node

func trigger_ability(deck_ref, battle_manager) -> bool:
	var targets = battle_manager.playerUnitsOnBF
	
	if targets.size() == 0:
		return false
	
	var random_unit = targets.pick_random()
	random_unit.attack += 2
	
	if random_unit.has_node("Attack"):
		random_unit.get_node("Attack").text = str(random_unit.attack)
	
	generate_meditate(battle_manager)
	return true

func generate_meditate(battle_manager):
	var deck_ref = battle_manager.get_node("../Deck")
	var hand_ref = battle_manager.get_node("../PlayerHand")
	var card_manager_ref = battle_manager.get_node("../CardManager")
	
	if deck_ref and hand_ref and card_manager_ref:
		var card_name = "Meditate"
		var card_scene = preload("res://Scenes/Card.tscn")
		var new_card = card_scene.instantiate()
		var card_data = deck_ref.cardDBRef.CARDS[card_name]
		new_card.name = card_name + "_" + str(randi())
		card_manager_ref.add_child(new_card)
		
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
		hand_ref.addCardToHand(new_card, 0.5) 
		new_card.get_node("AnimationPlayer").play("cardFlip")
