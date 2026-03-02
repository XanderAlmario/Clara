extends Node2D

const COLLISION_MASK_CARD = 1

var draggingCard
var screenSize
var isHovering

func _ready():
	screenSize = get_viewport_rect().size

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
