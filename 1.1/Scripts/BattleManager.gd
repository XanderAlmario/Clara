extends Node

const CARD_MOVE_SPEED = 0.5
const STARTING_HEALTH = 10
const ATTACK_OFFSET = 20

var battleTimer
var enemyUnitsOnBF = []
var playerUnitsOnBF = []
var playerUnitsAttacked = []
var playerHP
var enemyHP
var playerIsAttacking = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$"../EndTurnButton".visible
	battleTimer = $"../BattleTimer"
	battleTimer.one_shot = true
	battleTimer.wait_time = 1.0
	
	#playerHP = STARTING_HEALTH
	#$"../PlayerHP".text = str(playerHP)
	#enemyHP = STARTING_HEALTH
	#$"../EnemyHP".text = str(enemyHP)

func _on_end_turn_button_pressed():
	$"../EndTurnButton".disabled = true
	$"../InputManager".inputs_disabled = true
	$"../CardManager".unselect()
	playerUnitsAttacked = []
	rpc("change_turn")
	
@rpc("any_peer")
func change_turn():
	$"../Deck".resetDraw()
	$"../EndTurnButton".disabled = false
	$"../InputManager".inputs_disabled = false

func directAttack(attacker):
	$"../EndTurnButton".disabled = true
	playerIsAttacking = true
	playerUnitsAttacked.append(attacker)
	
	var player_id = multiplayer.get_unique_id
	rpc("direct_attack_here_and_replicate_client_opponent", player_id, attacker.name)
	await direct_attack_here_and_replicate_client_opponent(player_id, attacker.name)
	
	playerIsAttacking = false
	$"../EndTurnButton".disabled = false
	$"../EndTurnButton".visible = true

@rpc("any_peer")
func direct_attack_here_and_replicate_client_opponent(player_id, attacking_name):
	var attacker
	var pos_y
	
	attacking_name = str(attacking_name)
	
	if multiplayer.get_unique_id == player_id:
		attacker = $"../CardManager".get_node(attacking_name)
		pos_y = 0
	else:
		attacker = get_parent().get_parent().get_node("EnemyField/CardManager/"+attacking_name)
		pos_y = 1080
		
	var newPos = Vector2(attacker.position.x, pos_y)
	attacker.z_index = 5
	
	var tween = get_tree().create_tween()
	tween.tween_property(attacker, "position", newPos, CARD_MOVE_SPEED)
	await wait(0.015)
	
	if multiplayer.get_unique_id == player_id:
		enemyHP = max(0, enemyHP - attacker.attack)
		get_parent().get_parent().get_node("EnemyField/EnemyHP").text = str(enemyHP)
	else:
		playerHP = max(0, playerHP - attacker.attack)
		$"../PlayerHP".text = str(playerHP)
	
	var tween2 = get_tree().create_tween()
	tween2.tween_property(attacker, "position", attacker.cardSlot.position, CARD_MOVE_SPEED)
	attacker.z_index = 0
	await wait(1.0)

func unitAttack(attacker, target):
	playerIsAttacking = true
	$"../EndTurnButton".disabled = true
	$"../CardManager".selectedUnit = null
	playerUnitsAttacked.append(attacker)
	
	var player_id = multiplayer.get_unique_id
	attack_here_and_replicate_client_opponent(player_id, attacker.name, target.name)
	rpc("attack_here_and_replicate_client_opponent", player_id, attacker.name, target.name)
		
	playerIsAttacking = false
	$"../EndTurnButton".disabled = false

@rpc("any_peer")
func attack_here_and_replicate_client_opponent(player_id, attacking_name, defender_name):
	var attacker
	var target
	var y_offset
	
	attacking_name = str(attacking_name)
	defender_name = str(defender_name)
	
	print(attacking_name)
	
	if multiplayer.get_unique_id == player_id:
		attacker = $"../CardManager".get_node(attacking_name)
		target = get_parent().get_parent().get_node("EnemyField/CardManager/"+defender_name)
		y_offset = ATTACK_OFFSET
	else:
		attacker = get_parent().get_parent().get_node("EnemyField/CardManager/"+attacking_name)
		target = $"../CardManager".get_node(defender_name)
		y_offset = -ATTACK_OFFSET
	
	attacker.z_index = 5
	var newPos = Vector2(target.position.x, target.position.y + y_offset)
	
	var tween = get_tree().create_tween()
	tween.tween_property(attacker, "position", newPos, CARD_MOVE_SPEED)
	await wait(0.015)
	
	var tween2 = get_tree().create_tween()
	tween2.tween_property(attacker, "position", attacker.cardSlot.position, CARD_MOVE_SPEED)
	await wait(0.015)
	
	target.health = max(0, target.health - attacker.attack)
	target.get_node("Health").text = str(target.health)
	attacker.health = max(0, attacker.health - target.attack)
	attacker.get_node("Health").text = str(attacker.health)
	
	await wait(1.0)
	attacker.z_index = 0
	
	var cardWasDestroyed = false
	if (attacker.health == 0):
		if multiplayer.get_unique_id == player_id:
			destroyCard(attacker, "Player")
		else:
			destroyCard(attacker, "Enemy")
	if (target.health == 0):
		if multiplayer.get_unique_id == player_id:
			destroyCard(target, "Enemy")
		else:
			destroyCard(target, "Player")
		cardWasDestroyed = true
	
	if cardWasDestroyed:
		await wait(1.0)

func destroyCard(card, cardOwner):
	var newPos
	if cardOwner == "Player":
		card.get_node("Area2D/CollisionShape2D").disabled = true
		newPos = $"../PlayerGrave".position
		if card in playerUnitsOnBF:
			playerUnitsOnBF.erase(card)
		card.cardSlot.get_node("Area2D/CollisionShape2D").disabled = false
	else:
		newPos = get_parent().get_parent().get_node("EnemyField/EnemyGrave").position
		if card in enemyUnitsOnBF:
			enemyUnitsOnBF.erase(card)
		
	card.dead = true
	card.cardSlot.cardInSlot = false
	card.cardSlot = null
		
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", newPos, CARD_MOVE_SPEED)

func enemyCardSelected(target):
	var attacker = $"../CardManager".selectedUnit
	if attacker:
		if target in enemyUnitsOnBF:
			$"../CardManager".selectedUnit = null
			unitAttack(attacker, target)

func wait(waitTime):
	battleTimer.wait_time = waitTime
	battleTimer.start()
	await battleTimer.timeout
