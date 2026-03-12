extends Node

const CARD_MOVE_SPEED = 0.5
const STARTING_HEALTH = 10
const ATTACK_OFFSET = 20

var battleTimer
var emptyEnemyUnitSlots = []
var enemyUnitsOnBF = []
var playerUnitsOnBF = []
var playerHP
var enemyHP

# Called when the node enters the scene tree for the first time.
func _ready():
	battleTimer = $"../BattleTimer"
	battleTimer.one_shot = true
	battleTimer.wait_time = 1.0
	
	emptyEnemyUnitSlots.append($"../CardSlots/CardSlot4")
	emptyEnemyUnitSlots.append($"../CardSlots/CardSlot5")
	emptyEnemyUnitSlots.append($"../CardSlots/CardSlot6")
	
	playerHP = STARTING_HEALTH
	$"../PlayerHP".text = str(playerHP)
	enemyHP = STARTING_HEALTH
	$"../EnemyHP".text = str(enemyHP)

func _on_end_turn_button_pressed():
	enemyTurn()

func enemyTurn():
	$"../EndTurnButton".disabled = true
	$"../EndTurnButton".visible = false
	
	# Wait 1 second
	await wait(1)
	
	if $"../EnemyDeck".enemy_deck.size() != 0:
		$"../EnemyDeck".drawCard() 
		await wait(1)
	
	# Check if free unit slots, and if there is, play unit with strongest attack
	if emptyEnemyUnitSlots.size() != 0:
		# Play card in hand with highest attack
		await playStrongestUnit()
	
	if enemyUnitsOnBF.size() != 0:
		var attackingUnits = enemyUnitsOnBF.duplicate()
		for card in attackingUnits:
			if playerUnitsOnBF.size() != 0:
				var target = playerUnitsOnBF.pick_random()
				await unitAttack(card, target, "Enemy")
			else:
				await directAttack(card, "Enemy")
				 
	
	endEnemyTurn()	
	
func directAttack(attacker, playerAttacking):
	var newPosY
	if playerAttacking == "Enemy":
		newPosY = 1080
	else:
		newPosY = 0
	
	attacker.z_index = 5
	var newPos = Vector2(attacker.position.x, newPosY)
	
	var tween = get_tree().create_tween()
	tween.tween_property(attacker, "position", newPos, CARD_MOVE_SPEED)
	await wait(0.015)
	
	if playerAttacking == "Enemy":
		playerHP = max(0, playerHP - attacker.attack)
		$"../PlayerHP".text = str(playerHP)
	else:
		enemyHP = max(0, enemyHP - attacker.attack)
		$"../EnemyHP".text = str(enemyHP)
	
	var tween2 = get_tree().create_tween()
	tween2.tween_property(attacker, "position", attacker.cardSlot.position, CARD_MOVE_SPEED)
	attacker.z_index = 0
	await wait(1.0)
	
func unitAttack(attacker, target, playerAttacking):
	attacker.z_index = 5
	var newPos = Vector2(target.position.x, target.position.y + ATTACK_OFFSET)
	
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
		destroyCard(attacker, playerAttacking)
	if (target.health == 0):
		target.cardSlot.cardInSlot = false
		if playerAttacking == "Player":
			destroyCard(target, "Enemy")
			enemyUnitsOnBF.erase(target)
		else:
			destroyCard(target, "Player")
			playerUnitsOnBF.erase(target)
		cardWasDestroyed = true
	
	if cardWasDestroyed:
		await wait(1.0)

func destroyCard(card, cardOwner):
	var newPos
	if cardOwner == "Player":
		newPos = $"../PlayerGrave".position
	else:
		newPos = $"../EnemyGrave".position
		
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", newPos, CARD_MOVE_SPEED)

func playStrongestUnit():
	var enemyHand = $"../EnemyHand".enemyHand
	if enemyHand.size() == 0:
		endEnemyTurn()
		return
	# Get random empty slot
	var randomEmptySlot = emptyEnemyUnitSlots.pick_random()
	emptyEnemyUnitSlots.erase(randomEmptySlot)
	# Pick card with highest attack
	var strongestUnit = enemyHand[0]
	for card in enemyHand:
		if card.get_node("Attack").text > strongestUnit.get_node("Attack").text:
			strongestUnit = card
	# Animate card to slot
	var tween = get_tree().create_tween()
	tween.tween_property(strongestUnit, "position", randomEmptySlot.position, CARD_MOVE_SPEED)
	strongestUnit.get_node("AnimationPlayer").play("cardFlip")
	enemyUnitsOnBF.append(strongestUnit)
	# Remove card from hand
	$"../EnemyHand".removeCard(strongestUnit)
	strongestUnit.cardSlot = randomEmptySlot
	
	await wait(1)

func wait(waitTime):
	battleTimer.wait_time = waitTime
	battleTimer.start()
	await battleTimer.timeout

func endEnemyTurn():
	$"../Deck".resetDraw()
	# Reset player deck draw
	$"../EndTurnButton".visible = true
	$"../EndTurnButton".disabled = false
