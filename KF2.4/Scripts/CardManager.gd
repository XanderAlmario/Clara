extends Node2D

const COLLISION_MASK_CARD = 1
const COLLISION_BATTLEFIELD_SLOT = 2
const CARD_SPEED = 0.1
const CARD_SCENE_PATH = "res://Scenes/Card.tscn"
const DEFAULT_CARD_SCALE = Vector2(1, 1)
const DRAW_SPEED = 0.5
const CARD_BIGGER_SCALE = Vector2(1.1, 1.1)
const CARD_WIDTH = 200
const COLLISION_MASK_ENEMY_CARD = 8

var draggingCard
var screenSize
var isHovering
var playerHandRef
var BMRef
var selectedUnit
var timeWaiting
var cardDBRef
var unitsToFuture = []

func _ready():
	screenSize = get_viewport_rect().size
	playerHandRef = $"../PlayerHand"
	BMRef = $"../BattleManager"
	cardDBRef = preload("res://Scripts/CardDatabase.gd")
	$"../InputManager".connect("clickReleased", onClickReleased)

func _process(delta):
	if draggingCard:
		var mouse_pos = get_global_mouse_position()
		draggingCard.position = Vector2(clamp(mouse_pos.x, 0, screenSize.x), clamp(mouse_pos.y, 0, screenSize.y))

func cardClicked(card):
	if card.cardSlot:
		#if $"../BattleManager".isEnemyTurn == false:
		if $"../BattleManager".playerIsAttacking == false:
			if card not in $"../BattleManager".playerUnitsAttacked and card.canAttack:
				if $"../BattleManager".enemyUnitsOnBF.size() == 0:
					if $"../BattleManager".tut:
						$"../BattleManager".directAttack(card, "Player")
					else:
						$"../BattleManager".directAttack(card) #, "Player")
					return
				else:
					selectCard(card)
	else:
		dragging(card)

func selectCard(card):
	if selectedUnit:
		if selectedUnit == card:
			card.position.y += 20
			selectedUnit = null
		else:
			selectedUnit.position.y += 20
			selectedUnit = card
			card.position.y -= 20
	else:
		selectedUnit = card
		card.position.y -= 20

func dragging(card):
	card.scale = DEFAULT_CARD_SCALE
	draggingCard = card

func stopDragging():
	draggingCard.scale = CARD_BIGGER_SCALE
	
	var actual_cost = BMRef.get_card_purchase_cost(draggingCard)
	
	if actual_cost <= BMRef.playerDev:
		if draggingCard.cardType != "Unit":
			if draggingCard.spellScript:
				var momentumIncrease = 1
				for unit in $"../PlayerBattlefield".unitsInPlay:
					if unit.cardName == "Way of Astral Master":
						momentumIncrease = 2
						break
				for unit in $"../PlayerBattlefield".unitsInPlay:
					if unit.momentum:
						unit.attack += momentumIncrease
						unit.health += momentumIncrease
						unit.get_node("Attack").text = str(unit.attack)
						unit.get_node("Health").text = str(unit.health)
				if draggingCard.name == "Crusader's Might":
					draggingCard.spellScript.trigger_targeted_ability(null, BMRef)
					BMRef.playerPlayCard(actual_cost)
					playerHandRef.removeCard(draggingCard)
					draggingCard.queue_free()
					draggingCard = null
					return
				if draggingCard.spellScript.has_method("trigger_targeted_ability"):
					var target = checkEnemyTarget()
					if target and target in BMRef.enemyUnitsOnBF:
						draggingCard.spellScript.trigger_targeted_ability(target, BMRef)
							
						BMRef.playerPlayCard(actual_cost)
						playerHandRef.removeCard(draggingCard)
						draggingCard.queue_free() 
						draggingCard = null
						return
					else:
						playerHandRef.addCardToHand(draggingCard, CARD_SPEED)
						draggingCard = null
						return
						
				elif draggingCard.spellScript.has_method("trigger_ability"):
					var deckRef = get_tree().get_root().find_child("Deck", true, false)
					draggingCard.spellScript.trigger_ability(deckRef, BMRef)
						
					BMRef.playerPlayCard(actual_cost)
					playerHandRef.removeCard(draggingCard)
					draggingCard.queue_free() 
					draggingCard = null
					return
		
		var foundBF = checkCardSlot()
		if foundBF and foundBF.unitsInPlay.size() < foundBF.BFSize:
			var player_id = multiplayer.get_unique_id()
			play_card_here_and_for_clients_opponent(player_id, draggingCard.name, foundBF.name)
			rpc("play_card_here_and_for_clients_opponent", player_id, draggingCard.name, foundBF.name)
				
			BMRef.playerUnitsOnBF.append(draggingCard)
			draggingCard = null
			return
				
	playerHandRef.addCardToHand(draggingCard, CARD_SPEED)
	draggingCard = null

func setBlessing(card, blessing):
	if blessing == 1:
		card.health += 4
		card.get_node("Health").text = str(card.health)
		card.bodyguard = true
		print("Blessing activated: 1")
	elif blessing == 2:
		card.health += 2
		card.get_node("Health").text = str(card.health)
		card.attack += 2
		card.get_node("Attack").text = str(card.attack)
		card.evasive = true
		print("Blessing activated: 2")
	elif blessing == 3:
		card.lunge = true
		print("Blessing activated: 3")
	elif blessing == 4:
		card.holyShield = true
		card.fury = true
		print("Blessing activated: 4")
	elif blessing == 5:
		card.reincarnate = true
		print("Blessing activated: 5")
	elif blessing == 6:
		card.health += 4
		card.get_node("Health").text = str(card.health)
		card.attack += 5
		card.get_node("Health").text = str(card.attack)
		print("Blessing activated: 6")

@rpc("any_peer")
func play_card_here_and_for_clients_opponent(player_id, card_name, card_slot_name):
	var card
	var cardSlot
	var numGen = RandomNumberGenerator.new()
	var blessing = numGen.randi_range(1, 6)
	
	card_name = str(card_name)
	card_slot_name = str(card_slot_name)
	if multiplayer.get_unique_id() == player_id:
		card = get_node(card_name)
		cardSlot = $"../PlayerBattlefield"
		isHovering = false
		playerHandRef.removeCard(card)
		var tween = get_tree().create_tween()
		tween.tween_property(card, "position", cardSlot.position, 0.1)
		var final_price = BMRef.get_card_purchase_cost(card)
		BMRef.playerPlayCard(final_price)
		cardSlot.unitsInPlay.append(card)
	else:
		var opponentField = get_parent().get_parent().get_node("EnemyField")
		card = opponentField.get_node("CardManager/"+card_name)
		cardSlot = opponentField.get_node("EnemyBattlefield")
		opponentField.get_node("EnemyHand").removeCard(card)
		var tween = get_tree().create_tween()
		tween.tween_property(card, "position", cardSlot.position, 0.1)
		if card:
			cardSlot.unitsInPlay.append(card)
			card.get_node("AnimationPlayer").play("cardFlip")
			$"../BattleManager".enemyUnitsOnBF.append(card)
	
	updateCardsOnBF(cardSlot)
	
	if card:
		card.cardSlot = cardSlot
		card.z_index = 1
	
		if card.holyBlessing:
			card.holyBlessing = false
			setBlessing(card, blessing)
		
		if card.lunge:
			card.canAttack = true
		
		if card.cardName == "Way of Mercy Master":
			createChai()
		
		if card.cardName == "Banner Bearer":
			$"../BattleManager".increaseAuras()
		
		if card.cardName == "Uther Pureheart":
			var unitsInDeck = []
			var cardDBRef = preload("res://Scripts/CardDatabase.gd")
			for cardInDeck in $"../Deck".player_deck:
				if cardDBRef.CARDS[cardInDeck][3] == "Unit":
					unitsInDeck.append(cardInDeck)
			var randomUnit = unitsInDeck.pick_random()
			#$"../Deck".draw_for_self_and_enemy(randomUnit)
			$"../Deck".drawCard(randomUnit)
			playerHandRef.holyBlessingOnDrawnCard()
			
		if card.cardName == "Artimose Aetheron":
			unitsToFuture = []
			timeWaiting = 0
			var tween = get_tree().create_tween()
			for cardInHand in playerHandRef.playerHand:
				if cardInHand.cardType == "Unit":
					unitsToFuture.append(cardInHand)
			for unit in unitsToFuture:
				playerHandRef.removeCard(unit)
				tween.tween_property(unit, "position", $"../Exile".position, 0.1)
		
		if card.cardName == "Thaloran Lightguard":
			var playedAuras = []
			
			for cardInDeck in $"../Deck".player_deck: 
				if "Aura" in cardInDeck and cardInDeck not in playedAuras:
					playedAuras.append(cardInDeck)
					$"../Deck".player_deck.erase(cardInDeck)
					$"../Deck/RichTextLabel".text = str($"../Deck".player_deck.size())
					if cardInDeck == "Defender Aura":
						$"../BattleManager".activate_defender_aura()
					elif cardInDeck == "Fatigue Aura":
						$"../BattleManager".receive_fatigue_aura()

func createChai():
	var chai = "Cup of Chai"
	var cardScene = preload(CARD_SCENE_PATH)
	var newCard = cardScene.instantiate()
	var cardImgPath = str("res://Assets/" + chai + ".png")
	var cardDBRef = preload("res://Scripts/CardDatabase.gd")
	var cardData = cardDBRef.CARDS[chai]
	newCard.get_node("CardImage").texture = load(cardImgPath)
	
	newCard.cardName = chai
	newCard.cost = cardDBRef.CARDS[chai][0]
	newCard.cardType = str(cardDBRef.CARDS[chai][3])
	newCard.get_node("Cost").text = str(0)
	newCard.get_node("Ability").text = str(cardDBRef.CARDS[chai][4])
	
	newCard.get_node("Attack").visible = false
	newCard.get_node("Health").visible = false
	if cardData.size() > 15 and cardData[15] != null:
		var script_res = load(cardData[15])
		if script_res:
			newCard.spellScript = script_res.new()
		else:
			push_error("Could not find ability script at: " + cardData[8])
			newCard.spellScript = null
	else:
		newCard.spellScript = null
	
	$"../CardManager".add_child(newCard)
	newCard.name = "Card"
	$"../PlayerHand".addCardToHand(newCard, DRAW_SPEED)
	newCard.get_node("AnimationPlayer").play("cardFlip")

func updateCardsOnBF(BF):
	for i in range(BF.unitsInPlay.size()):
		var newPos = Vector2(calculateCardPos(BF, i), BF.position.y)
		var card = BF.unitsInPlay[i]
		card.posInBF = newPos
		moveCardToPos(card, newPos, CARD_SPEED)

func calculateCardPos(BF, index):
	var centerX = BF.position.x
	var totalWidth = (BF.unitsInPlay.size() - 1) * CARD_WIDTH
	var xOffset = centerX + index * CARD_WIDTH - totalWidth / 2
	return xOffset

func moveCardToPos(card, newPos, speed):
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", newPos, speed)

func unselect():
	if selectedUnit:
		selectedUnit.position.y += 20
		selectedUnit = null

func connectSignals(card):
	card.connect("hovering", hoveringCard)
	card.connect("stoppedHovering", stoppedHoveringCard)
	
func onClickReleased():
	if draggingCard:
		stopDragging()
	
func hoveringCard(card):
	if card.cardName:
		var cardImgPath = str("res://Assets/" + card.cardName + ".png")
		$"../Inspect".get_node("Image").texture = load(cardImgPath)
	$"../Inspect".get_node("Cost").text = str(card.cost)
	if card.cardType == "Unit":
		$"../Inspect".get_node("Attack").visible = true
		$"../Inspect".get_node("Health").visible = true
		$"../Inspect".get_node("Attack").text = str(card.attack)
		$"../Inspect".get_node("Health").text = str(card.health)
	else:
		$"../Inspect".get_node("Attack").visible = false
		$"../Inspect".get_node("Health").visible = false
	$"../Inspect".visible = true
	if card.cardSlot:
		if !isHovering:
			highlightCard(card, true)
			isHovering = true
	
func stoppedHoveringCard(card):
	#card.get_node("Inspect").visible = false
	$"../Inspect".visible = false
	if !card.dead:
		if !draggingCard && !card.cardSlot:
			highlightCard(card, false)
			var newCardHovering = checkCard()
			if newCardHovering:
				highlightCard(newCardHovering, true)
			else:
				isHovering = false
	
func highlightCard(card, hovering):
	if hovering:
		card.scale = CARD_BIGGER_SCALE
		card.z_index = 2
		#card.get_node("Inspect").position = Vector2(0, 0)
		#card.get_node("Inspect").visible = true
	else:
		card.scale = DEFAULT_CARD_SCALE
		card.z_index = 1

func checkCard():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_CARD
	var result = space_state.intersect_point(parameters)
	if (result.size() > 0):
		#return result[0].collider.get_parent()
		return highestZIndCard(result)
	return null

func highestZIndCard(cards):
	var highestZCard = cards[0].collider.get_parent()
	var highestZInd = highestZCard.z_index
	
	for i in range(1, cards.size()):
		var currentCard = cards[i].collider.get_parent()
		if currentCard.z_index > highestZInd:
			highestZCard = currentCard
			highestZInd = currentCard.z_index
	
	return highestZCard

func checkCardSlot():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_BATTLEFIELD_SLOT
	var result = space_state.intersect_point(parameters)
	if (result.size() > 0):
		return result[0].collider.get_parent()
	return null

func checkEnemyTarget():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_ENEMY_CARD
	var result = space_state.intersect_point(parameters)
	if (result.size() > 0):
		return result[0].collider.get_parent()
	return null
