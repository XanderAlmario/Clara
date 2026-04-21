extends Node

func trigger_ability(deck_ref, battle_manager) -> bool:
	if deck_ref:
		for i in range(2):
			if deck_ref.player_deck.size() > 0:
				var cardToDraw = deck_ref.player_deck[0]
				deck_ref.drawCard(cardToDraw)
				
	return true
