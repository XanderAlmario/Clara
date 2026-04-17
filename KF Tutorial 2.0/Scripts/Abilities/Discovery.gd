extends Node

func trigger_ability(deck_manager, _battle_manager):
	for i in range(2):
		deck_manager.resetDraw()
		deck_manager.drawCard()
	deck_manager.resetDraw()
