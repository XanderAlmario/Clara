extends Node

func trigger_ability(deck, battle_manager):
	battle_manager.spawn_token("Monk 1")
	battle_manager.spawn_token("Monk 2")
	return true
