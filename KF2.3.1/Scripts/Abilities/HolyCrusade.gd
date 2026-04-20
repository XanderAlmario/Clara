extends Node

func trigger_ability(deck, battle_manager):
	battle_manager.spawn_token("Paladin 1")
	battle_manager.spawn_token("Paladin 2")
	battle_manager.spawn_token("Paladin 3")
	return true
