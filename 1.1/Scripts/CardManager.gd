extends Node2D

const COLLISION_MASK_CARD = 1
const COLLISION_BATTLEFIELD_SLOT = 2
const CARD_SPEED = 1
const DEFAULT_CARD_SCALE = Vector2(1, 1)
const CARD_BIGGER_SCALE = Vector2(1.1, 1.1)

var draggingCard
var screenSize
var isHovering
var playerHandRef
var selectedUnit

func _ready():
	screenSize = get_viewport_rect().size
	playerHandRef = $"../PlayerHand"
	$"../InputManager".connect("clickReleased", onClickReleased)

func _process(delta):
	if draggingCard:
		var mouse_pos = get_global_mouse_position()
		draggingCard.position = Vector2(clamp(mouse_pos.x, 0, screenSize.x), clamp(mouse_pos.y, 0, screenSize.y))

func cardClicked(card):
	if card.cardSlot:
		if $"../BattleManager".playerIsAttacking == false:
			if card not in $"../BattleManager".playerUnitsAttacked:
				if $"../BattleManager".enemyUnitsOnBF.size() == 0:
					$"../BattleManager".directAttack(card)
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
			selectedUnit.position += 20
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
	var foundSlot = checkCardSlot()
	if foundSlot and !foundSlot.cardInSlot:
		
		var player_id = multiplayer.get_unique_id()
		play_card_here_and_for_clients_opponent(player_id, draggingCard.name, foundSlot.name)
		rpc("play_card_here_and_for_clients_opponent", player_id, draggingCard.name, foundSlot.name)
		
		$"../BattleManager".playerUnitsOnBF.append(draggingCard)
		draggingCard = null
		return
	playerHandRef.addCardToHand(draggingCard, CARD_SPEED)
	draggingCard = null
	
@rpc("any_peer")
func play_card_here_and_for_clients_opponent(player_id, card_name, card_slot_name):
	var card
	var cardSlot
	
	card_name = str(card_name)
	card_slot_name = str(card_slot_name)
	if multiplayer.get_unique_id() == player_id:
		card = get_node(card_name)
		cardSlot = $"../CardSlots".get_node(card_slot_name)
		isHovering = false
		playerHandRef.removeCard(draggingCard)
		var tween = get_tree().create_tween()
		tween.tween_property(card, "position", cardSlot.position, 0.1)
		cardSlot.get_node("Area2D/CollisionShape2D").disabled = true
	else:
		var opponentField = get_parent().get_parent().get_node("EnemyField")
		card = opponentField.get_node("CardManager/"+card_name)
		cardSlot = opponentField.get_node("CardSlots/"+card_slot_name)
		opponentField.get_node("EnemyHand").removeCard(card)
		var tween = get_tree().create_tween()
		tween.tween_property(card, "position", cardSlot.position, 0.1)
		if card:
			card.get_node("AnimationPlayer").play("cardFlip")
			$"../BattleManager".enemyUnitsOnBF.append(card)
		
	card.cardSlot = cardSlot
	card.z_index = -1
	cardSlot.cardInSlot = true
	

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
	if card.cardSlot:
		if !isHovering:
			highlightCard(card, true)
			isHovering = true
	
func stoppedHoveringCard(card):
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
