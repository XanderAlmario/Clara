extends Node2D

const STARTING_HEALTH = 10

func host_setup():
	$PlayerHP.text = str(STARTING_HEALTH)
	get_parent().get_node("EnemyField/EnemyHP").text = str(STARTING_HEALTH)
	$BattleManager.playerHP = STARTING_HEALTH
	$BattleManager.enemyHP = STARTING_HEALTH
	
	$EndTurnButton.disabled = true
	
	get_parent().get_node("EnemyField/EnemyDeck").deck_size = 8
	get_parent().get_node("EnemyField/EnemyDeck/RichTextLabel").text = "8"
	
	await $Deck.draw_initial_hand()
	
	$EndTurnButton.disabled = false
	
	$InputManager.inputs_disabled = false
	
func client_setup():
	$PlayerHP.text = str(STARTING_HEALTH)
	get_parent().get_node("EnemyField/EnemyHP").text = str(STARTING_HEALTH)
	$BattleManager.playerHP = STARTING_HEALTH
	$BattleManager.enemyHP = STARTING_HEALTH
	
	get_parent().get_node("EnemyField/EnemyDeck").deck_size = 8
	get_parent().get_node("EnemyField/EnemyDeck/RichTextLabel").text = "8"
	
	$Deck.draw_initial_hand()
