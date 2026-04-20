extends Node

const CARD_MOVE_SPEED = 0.1
const STARTING_HEALTH = 2
const ATTACK_OFFSET = 20
const MAX_DEVOTION = 10
const CARD_WIDTH = 200

var tut = true
var battleTimer
var emptyEnemyUnitSlots = []
var enemyUnitsOnBF = []
var playerUnitsOnBF = []
var playerUnitsAttacked = []
var playerHP
var playerDev = 0
var playerMaxDev = 0
var enemyHP
var enemyDev = 0
var enemyMaxDev = 0
var isEnemyTurn = false
var playerIsAttacking = false
var firstRound = true
var playerBF
var enemyBF
var enemyTurnCount = 0
var playerTurnCount = 1
var player_is_taxed_turns = 0  

# Called when the node enters the scene tree for the first time.
func _ready():
	battleTimer = $"../BattleTimer"
	battleTimer.one_shot = true
	battleTimer.wait_time = 1.0
	
	playerHP = STARTING_HEALTH
	$"../PlayerHP".text = str(playerHP)
	enemyHP = STARTING_HEALTH
	$"../EnemyHP".text = str(enemyHP)
	
	updatePlayerDev()
	updateEnemyDev()
	
	playerBF = $"../PlayerBattlefield"
	enemyBF = $"../EnemyBattlefield"
	
	if playerTurnCount == 1:
		$"../EndTurnButton".disabled = true

func _on_end_turn_button_pressed():
	if playerTurnCount == 1 and playerBF.unitsInPlay.size() == 1:
		$"../CardManager".unselect()
		playerUnitsAttacked = []
		if !firstRound:
			updateEnemyDev()
		else:
			firstRound = false
		playerTurnCount += 1
		enemyTurn()
	elif playerTurnCount >= 2:
		$"../CardManager".unselect()
		playerUnitsAttacked = []
		if !firstRound:
			updateEnemyDev()
		else:
			firstRound = false
		playerTurnCount += 1
		enemyTurn()
		
func get_card_purchase_cost(card):
	var base_cost = card.cost
	if player_is_taxed_turns > 0:
		print("AURA ACTIVE: Taxing ", card.name, " +1 Devotion.")
		return base_cost + 1
	return base_cost

func enemyTurn():
	$"../EndTurnButton".disabled = true
	$"../EndTurnButton".visible = false
	
	# Wait 1 second
	await wait(1)
	
	if $"../EnemyDeck".enemy_deck.size() > 0:
		$"../EnemyDeck".drawCard() 
		await wait(1)
	
	enemyTurnCount += 1
	
	#if enemyTurnCount == 1:
		##blah blah blah
		#pass
	# Check if free unit slots, and if there is, play unit with strongest attack
	if enemyBF.unitsInPlay.size() != enemyBF.BFSize:
		# Play card in hand with highest attack
		#await playStrongestUnit()
		await playUnit()
		
	
	#if enemyUnitsOnBF.size() != 0:
		#var attackingUnits = enemyUnitsOnBF.duplicate()
		#for card in attackingUnits:
			#if playerUnitsOnBF.size() != 0:
				#var target = playerUnitsOnBF.pick_random()
				#await unitAttack(card, target, "Enemy")
			#else:
				#await directAttack(card, "Enemy")
				 
	endEnemyTurn()	
	
func playUnit():
	var enemyHand = $"../EnemyHand".enemyHand
	var unitToPlay
	for card in enemyHand:
		if card.cost == 1:
			unitToPlay = card
			unitToPlay.get_node("AnimationPlayer").play("cardFlip")
			enemyUnitsOnBF.append(unitToPlay)
			enemyBF.unitsInPlay.append(unitToPlay)
			updateCardsOnBF(enemyBF)
			enemyPlayCard(unitToPlay.cost)
			# Remove card from hand
			$"../EnemyHand".removeCard(unitToPlay)
			unitToPlay.cardSlot = enemyBF
			break
	await wait(1)

func directAttack(attacker, playerAttacking):
	var newPosY
	if playerAttacking == "Enemy":
		newPosY = 1080
	else:
		$"../EndTurnButton".disabled = true
		$"../EndTurnButton".visible = false
		playerIsAttacking = true
		newPosY = 0
		playerUnitsAttacked.append(attacker)
		if attacker.fury and !attacker.firstAttack:
			playerUnitsAttacked.erase(attacker)
	
	attacker.z_index = 5
	var newPos = Vector2(attacker.position.x, newPosY)
	
	var tween = get_tree().create_tween()
	tween.tween_property(attacker, "position", newPos, CARD_MOVE_SPEED)
	await wait(0.015)
	
	var damageDone = attacker.attack
	if playerAttacking == "Enemy":
		playerHP = max(0, playerHP - damageDone)
		$"../PlayerHP".text = str(playerHP)
		if attacker.lifeDrain:
			enemyHP += damageDone
			$"../EnemyHP".text = str(enemyHP)
	else:
		enemyHP = max(0, enemyHP - damageDone)
		$"../EnemyHP".text = str(enemyHP)
		if attacker.lifeDrain:
			playerHP += damageDone
			$"../PlayerHP".text = str(playerHP)
	
	var tween2 = get_tree().create_tween()
	tween2.tween_property(attacker, "position", attacker.posInBF, CARD_MOVE_SPEED)
	attacker.z_index = 0
	await wait(1.0)
	if playerAttacking == "Player":
		playerIsAttacking = false
		$"../EndTurnButton".disabled = false
		if enemyHP <= 0:
			$"../TutorialInstruction".instructionShow()
			$"../TutorialInstruction".visible = true
			$"../EndTurnButton".disabled = true
			await wait(2)
			get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
		$"../EndTurnButton".visible = true
	attacker.firstAttack = true
	
func unitAttack(attacker, target, playerAttacking):
	if playerAttacking == "Player":
		playerIsAttacking = true
		$"../EndTurnButton".disabled = true
		$"../EndTurnButton".visible = false
		$"../CardManager".selectedUnit = null
		playerUnitsAttacked.append(attacker)
		if attacker.fury and !attacker.firstAttack:
			playerUnitsAttacked.erase(attacker)
			
	
	attacker.z_index = 5
	var newPos = Vector2(target.position.x, target.position.y + ATTACK_OFFSET)
	
	var tween = get_tree().create_tween()
	tween.tween_property(attacker, "position", newPos, CARD_MOVE_SPEED)
	await wait(0.015)
	
	var tween2 = get_tree().create_tween()
	tween2.tween_property(attacker, "position", attacker.posInBF, CARD_MOVE_SPEED)
	await wait(0.015)
	
	var damageAttackerDone = attacker.attack
	var damageTargetDone = target.attack
		
	if target.holyShield:
		attacker.health = max(0, attacker.health - damageTargetDone)
		attacker.get_node("Health").text = str(attacker.health)
		target.holyShield = false
	elif attacker.holyShield:
		target.health = max(0, target.health - damageTargetDone)
		target.get_node("Health").text = str(target.health)
		attacker.holyShield = false
	elif !target.holyShield and !attacker.holyShield:
		target.health = max(0, target.health - damageTargetDone)
		target.get_node("Health").text = str(target.health)
		attacker.health = max(0, attacker.health - damageTargetDone)
		attacker.get_node("Health").text = str(attacker.health)
	elif target.holyShield and attacker.holyShield:
		target.holyShield = false
		attacker.holyShield = false
	
	await wait(1.0)
	attacker.z_index = 0
	
	var cardWasDestroyed = false
	if (attacker.health == 0):
		destroyCard(attacker, playerAttacking)
		if playerAttacking == "Player":
			playerBF.unitsInPlay.erase(attacker)
		else:
			enemyBF.unitsInPlay.erase(attacker)
	if (target.health == 0):
		if playerAttacking == "Player":
			destroyCard(target, "Enemy")
			enemyBF.unitsInPlay.erase(target)
		else:
			destroyCard(target, "Player")
			playerBF.unitsInPlay.erase(target)
		cardWasDestroyed = true
		
	updateCardsOnBF(playerBF)
	updateCardsOnBF(enemyBF)
	if cardWasDestroyed:
		await wait(1.0)
		
	if playerAttacking == "Player":
		playerIsAttacking = false
		$"../EndTurnButton".disabled = false
		$"../EndTurnButton".visible = true
		if playerTurnCount == 2:
			$"../TutorialInstruction".instructionShow()
			$"../TutorialInstruction".visible = true
	attacker.firstAttack = true

func updateCardsOnBF(BF):
	for i in range(BF.unitsInPlay.size()):
			var newPos = Vector2(calculateCardPos(BF, i), BF.position.y)
			var card = BF.unitsInPlay[i]
			card.posInBF = newPos
			moveCardToPos(card, newPos, CARD_MOVE_SPEED)

func calculateCardPos(BF, index):
	var centerX = BF.position.x
	var totalWidth = (BF.unitsInPlay.size() - 1) * CARD_WIDTH
	var xOffset = centerX + index * CARD_WIDTH - totalWidth / 2
	return xOffset

func moveCardToPos(card, newPos, speed):
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", newPos, speed)

func destroyCard(card, cardOwner):
	var newPos
	if cardOwner == "Player":
		card.dead = true
		card.get_node("Area2D/CollisionShape2D").disabled = true
		newPos = $"../PlayerGrave".position
		if card in playerUnitsOnBF:
			playerUnitsOnBF.erase(card)
		card.cardSlot.get_node("Area2D/CollisionShape2D").disabled = false
	else:
		newPos = $"../EnemyGrave".position
		if card in enemyUnitsOnBF:
			enemyUnitsOnBF.erase(card)
		
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", newPos, CARD_MOVE_SPEED)

func enemyCardSelected(target):
	var attacker = $"../CardManager".selectedUnit
	if attacker:
		if target in enemyUnitsOnBF:
			$"../CardManager".selectedUnit = null
			unitAttack(attacker, target, "Player")

func wait(waitTime):
	battleTimer.wait_time = waitTime
	battleTimer.start()
	await battleTimer.timeout

func endEnemyTurn():
	$"../Deck".resetDraw()
	if $"../Deck".player_deck.size() > 0:
		$"../Deck".drawCard($"../Deck".player_deck[0])
	updatePlayerDev()
	for card in playerUnitsOnBF:
		card.canAttack = true
	isEnemyTurn = false
	$"../EndTurnButton".visible = true
	$"../EndTurnButton".disabled = false
	
	if playerTurnCount == 2 or playerTurnCount == 3:
		$"../TutorialInstruction".instructionShow()
		$"../TutorialInstruction".visible = true
	
func updatePlayerDev():
	if (playerMaxDev < MAX_DEVOTION):
		playerMaxDev += 1
	
	playerDev = playerMaxDev
	$"../PlayerDiv/PlayerMaxDev".text = str(playerMaxDev)
	$"../PlayerDiv/PlayerDev".text = str(playerDev)
	
func updateEnemyDev():
	if (enemyMaxDev < MAX_DEVOTION):
		enemyMaxDev += 1
	
	enemyDev = enemyMaxDev
	$"../EnemyDiv/EnemyMaxDev".text = str(enemyMaxDev)
	$"../EnemyDiv/EnemyDev".text = str(enemyDev)
	
func playerPlayCard(cost):
	playerDev -= cost
	$"../PlayerDiv/PlayerDev".text = str(playerDev)
	if playerTurnCount == 1:
		$"../TutorialInstruction".instructionShow()
		$"../TutorialInstruction".visible = true
		$"../EndTurnButton".disabled = false
	elif playerTurnCount == 2:
		$"../TutorialInstruction".instructionShow()
		$"../TutorialInstruction".visible = true
		$"../EndTurnButton".disabled = false
	
func enemyPlayCard(cost):
	enemyDev -= cost
	$"../EnemyDiv/EnemyDev".text = str(enemyDev)
