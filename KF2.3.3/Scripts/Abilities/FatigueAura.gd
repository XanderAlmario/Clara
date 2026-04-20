extends Node

func trigger_ability(_deck_ref, battle_manager) -> bool:
	battle_manager.rpc("receive_fatigue_aura")
	return true
