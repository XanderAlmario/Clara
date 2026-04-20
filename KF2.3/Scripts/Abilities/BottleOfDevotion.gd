extends Node

func trigger_ability(_deck_ref, battle_manager) -> bool:
	battle_manager.playerDev += 1
	return true
