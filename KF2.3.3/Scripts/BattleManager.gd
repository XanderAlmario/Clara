extends Node

signal game_end

const CARD_MOVE_SPEED = 0.1
const STARTING_HEALTH = 10
const ATTACK_OFFSET = 20
const MAX_DEVOTION = 10
const CARD_WIDTH = 200

var battleTimer
var emptyEnemyUnitSlots = []
var enemyUnitsOnBF = []
var playerUnitsOnBF = []
var playerUnitsAttacked = []
var playerHP
var playerDev = 10
var playerMaxDev = 10
var enemyHP
var enemyDev = 0
var enemyMaxDev = 0
#var isEnemyTurn = false
var playerIsAttacking = false
var firstRound = true
var playerBF
var enemyBF
var is_targeting_with_spell = false
var spell_card_waiting = null
var fatigue_aura_turns_left = 0
var player_is_taxed_turns = 0  
var enemy_is_taxed_turns = 0   
var defender_aura_turns_left = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	battleTimer = $"../BattleTimer"
	battleTimer.one_shot = true
	battleTimer.wait_time = 1.0
	
	#playerHP = STARTING_HEALTH
	#$"../PlayerHP".text = str(playerHP)
	#enemyHP = STARTING_HEALTH
	#$"../EnemyHP".text = str(enemyHP)
	
	updatePlayerDev()
	updateEnemyDev()
	
	playerBF = $"../PlayerBattlefield"
	#enemyBF = get_parent().get_parent().get_node("EnemyField/EnemyBattlefield")

func _on_end_turn_button_pressed():
	if defender_aura_turns_left > 0:
		spawn_token("Paladin Defender")
		defender_aura_turns_left -= 1
		if defender_aura_turns_left == 0:
			print("Defender Aura has ended.")
	if player_is_taxed_turns > 0:
		player_is_taxed_turns -= 1
	rpc("enemy_finished_tax_turn")
	$"../CardManager".unselect()
	updatePlayerDev()
	#playerUnitsAttacked = []
	#if !firstRound:
		#updateEnemyDev()
	#else:
		#firstRound = false
	#enemyTurn()
	$"../EndTurnButton".disabled = true
	$"../InputManager".inputs_disabled = true
	playerUnitsAttacked = []
	rpc("change_turn")

@rpc("any_peer")
func change_turn():
	$"../Deck".resetDraw()
	var cardToDraw = $"../Deck".player_deck[0]
	$"../Deck".drawCard(cardToDraw)
	$"../EndTurnButton".disabled = false
	$"../InputManager".inputs_disabled = false

#func enemyTurn():
	#$"../EndTurnButton".disabled = true
	#
	## Wait 1 second
	#await wait(1)
	#
	#if $"../EnemyDeck".enemy_deck.size() > 0:
		#$"../EnemyDeck".drawCard() 
		#await wait(1)
	#
	## Check if free unit slots, and if there is, play unit with strongest attack
	#if enemyBF.unitsInPlay.size() != enemyBF.BFSize:
		## Play card in hand with highest attack
		#await playStrongestUnit()
	#
	#if enemyUnitsOnBF.size() != 0:
		#var attackingUnits = enemyUnitsOnBF.duplicate()
		#for card in attackingUnits:
			#if playerUnitsOnBF.size() != 0:
				#var target = playerUnitsOnBF.pick_random()
				#await unitAttack(card, target, "Enemy")
			#else:
				#await directAttack(card, "Enemy")
				 #
	#endEnemyTurn()	
	
func directAttack(attacker): #, playerAttacking)
	#var newPosY
	#if playerAttacking == "Enemy":
		#newPosY = 1080
	#else:
		#$"../EndTurnButton".disabled = true
		#$"../EndTurnButton".visible = false
		#playerIsAttacking = true
		#newPosY = 0
		#playerUnitsAttacked.append(attacker)
		#if attacker.fury and !attacker.firstAttack:
			#playerUnitsAttacked.erase(attacker)
	#
	#attacker.z_index = 5
	#var newPos = Vector2(attacker.position.x, newPosY)
	#
	#var tween = get_tree().create_tween()
	#tween.tween_property(attacker, "position", newPos, CARD_MOVE_SPEED)
	#await wait(0.015)
	#
	#var damageDone = attacker.attack
	#if playerAttacking == "Enemy":
		#playerHP = max(0, playerHP - damageDone)
		#$"../PlayerHP".text = str(playerHP)
		#if attacker.lifeDrain:
			#enemyHP += damageDone
			#$"../EnemyHP".text = str(enemyHP)
	#else:
		#enemyHP = max(0, enemyHP - damageDone)
		#$"../EnemyHP".text = str(enemyHP)
		#if attacker.lifeDrain:
			#playerHP += damageDone
			#$"../PlayerHP".text = str(playerHP)
	#
	#var tween2 = get_tree().create_tween()
	#tween2.tween_property(attacker, "position", attacker.posInBF, CARD_MOVE_SPEED)
	#attacker.z_index = 0
	#await wait(1.0)
	#if playerAttacking == "Player":
		#playerIsAttacking = false
		#$"../EndTurnButton".disabled = false
		#$"../EndTurnButton".visible = true
	#attacker.firstAttack = true
	
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
		if attacker.fury and !attacker.firstAttack:
			playerUnitsAttacked.erase(attacker)
	else:
		attacker = get_parent().get_parent().get_node("EnemyField/CardManager/"+attacking_name)
		pos_y = 1080
	
	if attacker:
		var newPos = Vector2(attacker.position.x, pos_y)
		attacker.z_index = 5
		
		var tween = get_tree().create_tween()
		tween.tween_property(attacker, "position", newPos, CARD_MOVE_SPEED)
		await wait(0.015)
		
		var damageDone = attacker.attack
		if !damageDone:
			damageDone = 0
		if multiplayer.get_unique_id == player_id:
			enemyHP = max(0, enemyHP - damageDone)
			get_parent().get_parent().get_node("EnemyField/EnemyHP").text = str(enemyHP)
			if attacker.lifeDrain:
				playerHP += damageDone
				$"../PlayerHP".text = str(playerHP)
		else:
			playerHP = max(0, playerHP - damageDone)
			$"../PlayerHP".text = str(playerHP)
			if attacker.lifeDrain:
				enemyHP += damageDone
				get_parent().get_parent().get_node("EnemyField/EnemyHP").text = str(enemyHP)
		
		var tween2 = get_tree().create_tween()      #attacker.cardSlot.position
		tween2.tween_property(attacker, "position", attacker.posInBF, CARD_MOVE_SPEED)
		attacker.z_index = 0
		await wait(1.0)
		playerIsAttacking = false
		$"../EndTurnButton".disabled = false
		$"../EndTurnButton".visible = true
		attacker.firstAttack = true
		
	checkForGameEnd()
	
func unitAttack(attacker, target): # , playerAttacking)
	#if playerAttacking == "Player":
		#playerIsAttacking = true
		#$"../EndTurnButton".disabled = true
		#$"../EndTurnButton".visible = false
		#$"../CardManager".selectedUnit = null
		#playerUnitsAttacked.append(attacker)
		#if attacker.fury and !attacker.firstAttack:
			#playerUnitsAttacked.erase(attacker)
	#
	#attacker.z_index = 5
	#var newPos = Vector2(target.position.x, target.position.y + ATTACK_OFFSET)
	#
	#var tween = get_tree().create_tween()
	#tween.tween_property(attacker, "position", newPos, CARD_MOVE_SPEED)
	#await wait(0.015)
	#
	#var tween2 = get_tree().create_tween()
	#tween2.tween_property(attacker, "position", attacker.posInBF, CARD_MOVE_SPEED)
	#await wait(0.015)
	#
	#var damageAttackerDone = attacker.attack
	#var damageTargetDone = target.attack
	#var targetIsPlayer = false
	#if attacker in enemyBF:
		#targetIsPlayer = true
		#
	#if target.holyShield:
		#attacker.health = max(0, attacker.health - damageTargetDone)
		#attacker.get_node("Health").text = str(attacker.health)
		#target.holyShield = false
		#if target.lifeDrain:
			#$"../EnemyHP".text = str(enemyHP)
	#elif attacker.holyShield:
		#target.health = max(0, target.health - damageTargetDone)
		#target.get_node("Health").text = str(target.health)
		#attacker.holyShield = false
	#elif !target.holyShield and !attacker.holyShield:
		#target.health = max(0, target.health - damageTargetDone)
		#target.get_node("Health").text = str(target.health)
		#attacker.health = max(0, attacker.health - damageTargetDone)
		#attacker.get_node("Health").text = str(attacker.health)
	#elif target.holyShield and attacker.holyShield:
		#target.holyShield = false
		#attacker.holyShield = false
	#
	#await wait(1.0)
	#attacker.z_index = 0
	#
	#var cardWasDestroyed = false
	#if (attacker.health == 0):
		#destroyCard(attacker, playerAttacking)
		#if playerAttacking == "Player":
			#playerBF.unitsInPlay.erase(attacker)
		#else:
			#enemyBF.unitsInPlay.erase(attacker)
	#if (target.health == 0):
		#if playerAttacking == "Player":
			#destroyCard(target, "Enemy")
			#enemyBF.unitsInPlay.erase(target)
		#else:
			#destroyCard(target, "Player")
			#playerBF.unitsInPlay.erase(target)
		#cardWasDestroyed = true
		#
	#updateCardsOnBF(playerBF)
	#updateCardsOnBF(enemyBF)
	#if cardWasDestroyed:
		#await wait(1.0)
		#
	#if playerAttacking == "Player":
		#playerIsAttacking = false
		#$"../EndTurnButton".disabled = false
		#$"../EndTurnButton".visible = true
	#attacker.firstAttack = true
	
	playerIsAttacking = true
	$"../EndTurnButton".disabled = true
	$"../CardManager".selectedUnit = null
	playerUnitsAttacked.append(attacker)
	if attacker.fury and !attacker.firstAttack:
		playerUnitsAttacked.erase(attacker)
	
	var player_id = multiplayer.get_unique_id
	attack_here_and_replicate_client_opponent(player_id, attacker.name, target.name)
	rpc("attack_here_and_replicate_client_opponent", player_id, attacker.name, target.name)
		
	playerIsAttacking = false
	$"../EndTurnButton".disabled = false
	attacker.firstAttack = true

@rpc("any_peer")
func attack_here_and_replicate_client_opponent(player_id, attacking_name, defender_name):
	var attacker
	var target
	var y_offset
	
	if not enemyBF:
		enemyBF = get_node_or_null("../../EnemyField/EnemyBattlefield")
		if not enemyBF:
			enemyBF = get_node_or_null("../EnemyBattlefield")
	
	attacking_name = str(attacking_name)
	defender_name = str(defender_name)
	
	if multiplayer.get_unique_id == player_id:
		attacker = $"../CardManager".get_node(attacking_name)
		target = get_parent().get_parent().get_node("EnemyField/CardManager/"+defender_name)
		y_offset = ATTACK_OFFSET
	else:
		attacker = get_parent().get_parent().get_node("EnemyField/CardManager/"+attacking_name)
		target = $"../CardManager".get_node(defender_name)
		y_offset = -ATTACK_OFFSET
	
	if attacker:
		attacker.z_index = 5
		var newPos = Vector2(target.position.x, target.position.y + y_offset)
		
		var tween = get_tree().create_tween()
		tween.tween_property(attacker, "position", newPos, CARD_MOVE_SPEED)
		await wait(0.015)
		
		var tween2 = get_tree().create_tween()
		tween2.tween_property(attacker, "position", attacker.posInBF, CARD_MOVE_SPEED)
		await wait(0.015)
		
		var damageAttackerDone = attacker.attack
		var damageTargetDone = target.attack
		#var targetIsPlayer = false
		#if attacker in enemyBF:
			#targetIsPlayer = true
		
		if target and attacker:
			if target.fastHands and !attacker.fastHands:
				if target.holyShield:
					attacker.health = max(0, attacker.health - damageTargetDone)
					attacker.get_node("Health").text = str(attacker.health)
					if attacker.health != 0:
						target.holyShield = false
				elif attacker.holyShield:
					target.health = max(0, target.health - damageAttackerDone)
					target.get_node("Health").text = str(target.health)
					attacker.holyShield = false
				elif !target.holyShield and !attacker.holyShield:
					attacker.health = max(0, attacker.health - damageTargetDone)
					attacker.get_node("Health").text = str(attacker.health)
					if attacker.health != 0:
						target.health = max(0, target.health - damageAttackerDone)
						target.get_node("Health").text = str(target.health)
				elif target.holyShield and attacker.holyShield:
					target.holyShield = false
					attacker.holyShield = false
					
			elif !target.fastHands and attacker.fastHands:
				if target.holyShield:
					attacker.health = max(0, attacker.health - damageTargetDone)
					attacker.get_node("Health").text = str(attacker.health)
					target.holyShield = false
				elif attacker.holyShield:
					target.health = max(0, target.health - damageAttackerDone)
					target.get_node("Health").text = str(target.health)
					if target.health != 0:
						attacker.holyShield = false
				elif !target.holyShield and !attacker.holyShield:
					target.health = max(0, target.health - damageAttackerDone)
					target.get_node("Health").text = str(target.health)
					if target.health != 0:
						attacker.health = max(0, attacker.health - damageTargetDone)
						attacker.get_node("Health").text = str(attacker.health)
				elif target.holyShield and attacker.holyShield:
					target.holyShield = false
					attacker.holyShield = false
					
			elif target.fastHands == attacker.fastHands:
				if target.holyShield:
					attacker.health = max(0, attacker.health - damageTargetDone)
					attacker.get_node("Health").text = str(attacker.health)
					target.holyShield = false
				elif attacker.holyShield:
					target.health = max(0, target.health - damageAttackerDone)
					target.get_node("Health").text = str(target.health)
					attacker.holyShield = false
				elif !target.holyShield and !attacker.holyShield:
					target.health = max(0, target.health - damageAttackerDone)
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
			if attacker.reincarnate:
				reviveCard(attacker)
			elif multiplayer.get_unique_id == player_id:
				destroyCard(attacker, "Player")
				playerBF.unitsInPlay.erase(attacker)
			else:
				destroyCard(attacker, "Enemy")
				enemyBF.unitsInPlay.erase(attacker)
		if (target.health == 0):
			if target.reincarnate:
				reviveCard(target)
			elif multiplayer.get_unique_id == player_id:
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
	
	checkForGameEnd()

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

func checkForGameEnd():
	print("check")
	print(playerHP)
	print(enemyHP)
	
	if playerHP <= 0:
		emit_signal("game_end", false)
	elif enemyHP <= 0:
		emit_signal("game_end", true)

func reviveCard(card):
	card.reincarnate = false
	card.attack = 1
	card.health = 1
	card.get_node("Attack").text = str(card.attack)
	card.get_node("Health").text = str(card.health)

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
	card.cardSlot = null
	
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", newPos, CARD_MOVE_SPEED)

func enemyCardSelected(target):
	var attacker = $"../CardManager".selectedUnit
	var bodyguardInBF = false
	
	for card in enemyUnitsOnBF:
		if card.bodyguard:
			bodyguardInBF = true
			break
	
	if attacker:
		if (target in enemyUnitsOnBF and !bodyguardInBF) or (bodyguardInBF and target.bodyguard):
			$"../CardManager".selectedUnit = null
			unitAttack(attacker, target) # , "Player"

#func playStrongestUnit():
	#var enemyHand = $"../EnemyHand".enemyHand
	#if enemyHand.size() == 0:
		#endEnemyTurn()
		#return
	## Get random empty slot
	##var randomEmptySlot = emptyEnemyUnitSlots.pick_random()
	##emptyEnemyUnitSlots.erase(randomEmptySlot)
	## Pick card with highest attack
	#var strongestUnit
	#for card in enemyHand:
		#if card.cost <= enemyDev:
			#strongestUnit = card
			#break
	#if strongestUnit:
		#for card in enemyHand:
			#if card.attack > strongestUnit.attack and card.cost <= enemyDev:
				#strongestUnit = card
		## Animate card to slot
		##var tween = get_tree().create_tween()
		##tween.tween_property(strongestUnit, "position", randomEmptySlot.position, CARD_MOVE_SPEED)
		#strongestUnit.get_node("AnimationPlayer").play("cardFlip")
		#enemyUnitsOnBF.append(strongestUnit)
		#enemyBF.unitsInPlay.append(strongestUnit)
		#updateCardsOnBF(enemyBF)
		#enemyPlayCard(strongestUnit.cost)
		## Remove card from hand
		#$"../EnemyHand".removeCard(strongestUnit)
		#strongestUnit.cardSlot = enemyBF
	#
	#await wait(1)

func wait(waitTime):
	battleTimer.wait_time = waitTime
	battleTimer.start()
	await battleTimer.timeout

#func endEnemyTurn():
	#$"../Deck".resetDraw()
	#if $"../Deck".player_deck.size() > 0:
		#$"../Deck".drawCard()
	#updatePlayerDev()
	#for card in playerUnitsOnBF:
		#card.canAttack = true
	##isEnemyTurn = false
	#$"../EndTurnButton".visible = true
	#$"../EndTurnButton".disabled = false
	
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
	#$"../EnemyDiv/EnemyMaxDev".text = str(enemyMaxDev)
	#$"../EnemyDiv/EnemyDev".text = str(enemyDev)
	
func playerPlayCard(cost):
	playerDev -= cost
	$"../PlayerDiv/PlayerDev".text = str(playerDev)
	
func enemyPlayCard(cost):
	enemyDev -= cost
	$"../EnemyDiv/EnemyDev".text = str(enemyDev)

func resolve_spell_targeting(target):
	if target and spell_card_waiting:
		var spell_cost = spell_card_waiting.cost
		if spell_card_waiting.cardType != "Unit" and player_is_taxed_turns > 0:
			spell_cost += 1
		
		if spell_card_waiting.spellScript and spell_card_waiting.spellScript.has_method("trigger_targeted_ability"):
			spell_card_waiting.spellScript.trigger_targeted_ability(target, self, true)
		
		var player_id = multiplayer.get_unique_id()
		rpc("sync_targeted_spell", player_id, target.name)
		playerPlayCard(spell_cost)
		spell_card_waiting.queue_free()
		
	is_targeting_with_spell = false
	spell_card_waiting = null

func cancel_spell_targeting():
	if spell_card_waiting:
		spell_card_waiting.visible = true
		$"../PlayerHand".addCardToHand(spell_card_waiting, CARD_MOVE_SPEED)
	
	is_targeting_with_spell = false
	spell_card_waiting = null

@rpc("any_peer")
func sync_targeted_spell(caster_id, target_name):
	if multiplayer.get_unique_id() != caster_id:
		var target = $"../CardManager".get_node_or_null(str(target_name))
		if target:
			var damage = 2
			target.health = max(0, target.health - damage)
			if target.has_node("Health"):
				target.get_node("Health").text = str(target.health)
			if target.health <= 0:
				destroyCard(target, "Player") 
				if target in playerBF.unitsInPlay:
					playerBF.unitsInPlay.erase(target)
					
				updateCardsOnBF(playerBF)
				updateCardsOnBF(enemyBF)

@rpc("any_peer")
func receive_fatigue_aura():
	player_is_taxed_turns = 2 
	print("I am now taxed.")

func get_card_purchase_cost(card):
	var base_cost = card.cost
	if player_is_taxed_turns > 0:
		print("AURA ACTIVE: Taxing ", card.name, " +1 Devotion.")
		return base_cost + 1
	return base_cost

func activate_defender_aura():
	defender_aura_turns_left = 3

func spawn_token(token_name):
	if playerBF.unitsInPlay.size() >= playerBF.BFSize:
		print("Battlefield is full.")
		return
		
	var card_scene = preload("res://Scenes/Card.tscn")
	var new_card = card_scene.instantiate()
	
	var unique_name = token_name.replace(" ", "") + str(randi())
	new_card.name = unique_name
	
	$"../CardManager".add_child(new_card)
	
	var cardDB = preload("res://Scripts/CardDatabase.gd")
	var card_data = cardDB.CARDS[token_name]
	
	new_card.cost = card_data[0]
	new_card.attack = card_data[1]
	new_card.health = card_data[2]
	new_card.cardType = card_data[3]
	new_card.lunge = card_data[5]
	new_card.fury = card_data[6]
	new_card.holyShield = card_data[7]
	new_card.lifeDrain = card_data[8]
	new_card.fastHands = card_data[9]
	new_card.momentum = card_data[10]
	new_card.bodyguard = card_data[11]
	new_card.holyBlessing = card_data[12]
	new_card.reincarnate = card_data[13]
	new_card.evasive = card_data[14]
	new_card.spellScript = null
	
	if new_card.has_node("Attack"): new_card.get_node("Attack").text = str(new_card.attack)
	if new_card.has_node("Health"): new_card.get_node("Health").text = str(new_card.health)
	
	var image_path = "res://Assets/" + token_name + ".png"
	var token_texture = load(image_path) 
	
	if token_texture == null:
		print("ERROR: Godot could not find the image at: " + image_path)
		
	if new_card.has_node("CardImage"):
		new_card.get_node("CardImage").texture = token_texture
		
	if new_card.has_node("AnimationPlayer"):
		new_card.get_node("AnimationPlayer").play("cardFlip")
	
	playerBF.unitsInPlay.append(new_card)
	playerUnitsOnBF.append(new_card)
	new_card.cardSlot = playerBF
	updateCardsOnBF(playerBF)
	
	var player_id = multiplayer.get_unique_id()
	rpc("sync_spawn_token", player_id, unique_name, token_name)

@rpc("any_peer")
func sync_spawn_token(player_id, unique_card_name, token_name):
	if multiplayer.get_unique_id() == player_id:
		return 
		
	var card_scene = preload("res://Scenes/Card.tscn")
	var new_card = card_scene.instantiate()
	new_card.name = unique_card_name
	
	var cardDB = preload("res://Scripts/CardDatabase.gd")
	var card_data = cardDB.CARDS[token_name]
	
	new_card.cost = card_data[0]
	new_card.attack = card_data[1]
	new_card.health = card_data[2]
	new_card.cardType = card_data[3]
	new_card.lunge = card_data[5]
	new_card.fury = card_data[6]
	new_card.holyShield = card_data[7]
	new_card.lifeDrain = card_data[8]
	new_card.fastHands = card_data[9]
	new_card.momentum = card_data[10]
	new_card.bodyguard = card_data[11]
	new_card.holyBlessing = card_data[12]
	new_card.reincarnate = card_data[13]
	new_card.evasive = card_data[14]
	new_card.spellScript = null
	
	if new_card.has_node("Attack"): new_card.get_node("Attack").text = str(new_card.attack)
	if new_card.has_node("Health"): new_card.get_node("Health").text = str(new_card.health)
	
	var image_path = "res://Assets/" + token_name + ".png"
	var token_texture = load(image_path) 
	
	if token_texture == null:
		print("ERROR: Godot could not find the image at: " + image_path)
		
	if new_card.has_node("CardImage"):
		new_card.get_node("CardImage").texture = token_texture
		
	if new_card.has_node("AnimationPlayer"):
		new_card.get_node("AnimationPlayer").play("cardFlip")
	
	if new_card.has_node("Area2D"):
		new_card.get_node("Area2D").collision_layer = 8
		new_card.get_node("Area2D").collision_mask = 8
	
	var opponentField = get_parent().get_parent().get_node("EnemyField")
	opponentField.get_node("CardManager").add_child(new_card)
	
	var cardSlot = opponentField.get_node("EnemyBattlefield")
	cardSlot.unitsInPlay.append(new_card)
	enemyUnitsOnBF.append(new_card)
	
	new_card.cardSlot = cardSlot
	updateCardsOnBF(cardSlot)
