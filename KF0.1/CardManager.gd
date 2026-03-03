extends Node2D

const COLLISION_MASK_CARD = 1
const COLLISION_MASK_CARD_SLOT = 2

var draggingCard
var screenSize
var isHovering
var playerHandRef

func _ready():
	screenSize = get_viewport_rect().size
	playerHandRef = $"../PlayerHand"

func _process(delta):
	if draggingCard:
		var mouse_pos = get_global_mouse_position()
		draggingCard.position = Vector2(clamp(mouse_pos.x, 0, screenSize.x), clamp(mouse_pos.y, 0, screenSize.y))

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var card = checkCard()
			if card:
				dragging(card)
		else:
			if draggingCard:
				stopDragging()
			
func dragging(card):
	card.scale = Vector2(1, 1)
	draggingCard = card

func stopDragging():
	draggingCard.scale = Vector2(1.05, 1.05)
	var foundSlot = checkCardSlot()
	if foundSlot and !foundSlot.cardInSlot:
		var tween = get_tree().create_tween()
		tween.tween_property(draggingCard, "position", foundSlot.position, 0.1)
		draggingCard.get_node("Area2D/CollisionShape2D").disabled = true
		foundSlot.cardInSlot = true
		playerHandRef.removeCard(draggingCard)
	elif !foundSlot or foundSlot.cardInSlot:
		playerHandRef.addCardToHand(draggingCard)
	draggingCard = null

func connectSignals(card):
	card.connect("hovering", hoveringCard)
	card.connect("stoppedHovering", stoppedHoveringCard)
	
func hoveringCard(card):
	if !isHovering:
		highlightCard(card, true)
		isHovering = true
	
func stoppedHoveringCard(card):
	if !draggingCard:
		highlightCard(card, false)
		var newCardHovering = checkCard()
		if newCardHovering:
			highlightCard(newCardHovering, true)
		else:
			isHovering = false
	
func highlightCard(card, hovering):
	if hovering:
		card.scale = Vector2(1.05, 1.05)
		card.z_index = 2
	else:
		card.scale = Vector2(1, 1)
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
	parameters.collision_mask = COLLISION_MASK_CARD_SLOT
	var result = space_state.intersect_point(parameters)
	if (result.size() > 0):
		return result[0].collider.get_parent()
	return null
