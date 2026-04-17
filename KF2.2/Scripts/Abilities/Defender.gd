extends Node

func trigger_ability(deck, battle_manager):
	battle_manager.activate_defender_aura()
	print("Defender Aura activated!")
	return true
