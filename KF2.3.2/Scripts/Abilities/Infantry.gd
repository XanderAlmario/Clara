extends Node

func trigger_ability(deck, battle_manager):
	battle_manager.spawn_token("Knight 4")
	battle_manager.spawn_token("Knight 2")
	battle_manager.spawn_token("Knight 1")
	return true
