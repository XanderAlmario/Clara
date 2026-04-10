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
var playedUnit = false

func _ready():
	screenSize = get_viewport_rect().size
	playerHandRef = $"../PlayerHand"
	$"../InputManager".connect("clickReleased", onClickReleased)

func _process(delta):
	if draggingCard:
		var mouse_pos = get_global_mouse_position()
		draggingCard.position = Vector2(clamp(mouse_pos.x, 0, screenSize.x), clamp(mouse_pos.y, 0, screenSize.y))

func dragging(card):
	card.scale = DEFAULT_CARD_SCALE
	draggingCard = card

func stopDragging():
	draggingCard.scale = CARD_BIGGER_SCALE
	var foundSlot = checkCardSlot()
	if foundSlot and !foundSlot.cardInSlot:
		if draggingCard.cardType == "Unit" && playedUnit == false:
			playedUnit = true
			var tween = get_tree().create_tween()
			tween.tween_property(draggingCard, "position", foundSlot.position, 0.1)
			draggingCard.get_node("Area2D/CollisionShape2D").disabled = true
			draggingCard.z_index = -1
			foundSlot.cardInSlot = true
			playerHandRef.removeCard(draggingCard)
			draggingCard = null
			return
	playerHandRef.addCardToHand(draggingCard, CARD_SPEED)
	draggingCard = null

func connectSignals(card):
	card.connect("hovering", hoveringCard)
	card.connect("stoppedHovering", stoppedHoveringCard)
	
func onClickReleased():
	if draggingCard:
		stopDragging()
	
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
