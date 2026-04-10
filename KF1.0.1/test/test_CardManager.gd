extends GutTest

const CardManagerScript = preload("res://Scripts/CardManager.gd")

var manager = null
var root = null

func before_each():
	root = Node2D.new()
	add_child_autofree(root)
	
	var input = Node2D.new()
	input.name = "InputManager"
	input.add_user_signal("clickReleased") 
	root.add_child(input)
	
	var hand = Node2D.new()
	hand.name = "PlayerHand"
	hand.set_script(load("res://Scripts/PlayerHand.gd"))
	root.add_child(hand)
	
	var battle = Node2D.new()
	battle.name = "BattleManager"
	battle.set("playerUnitsOnBF", []) 
	root.add_child(battle)
	
	manager = CardManagerScript.new()
	manager.name = "CardManager"
	root.add_child(manager)

func create_placeholder():
	var card = Node2D.new()
	card.set_script(load("res://Scripts/Card.gd")) 
	manager.add_child(card)
	return card

func test_highlight_card():
	var card = create_placeholder()
	card.scale = Vector2(1, 1)
	
	manager.highlightCard(card, true)
	assert_eq(card.scale, Vector2(1.1, 1.1), "Card should scale up when highlighted")
	assert_eq(card.z_index, 2, "Highlighted card should be on top (Z=2)")
	
	manager.highlightCard(card, false)
	assert_eq(card.scale, Vector2(1, 1), "Card should return to default scale")
	assert_eq(card.z_index, 1, "Normal card should have Z=1")

func test_dragging_starts():
	var card = create_placeholder()
	manager.dragging(card)
	
	assert_eq(manager.draggingCard, card, "Manager should track the dragged card")
	assert_eq(card.scale, Vector2(1, 1), "Card should reset scale while dragging")

func test_highest_z_index_selection():
	var card1 = create_placeholder()
	card1.z_index = 5
	var area1 = Area2D.new()
	card1.add_child(area1)
	
	var card2 = create_placeholder()
	card2.z_index = 10
	var area2 = Area2D.new()
	card2.add_child(area2)
	
	var mock_results = [
		{"collider": area1},
		{"collider": area2}
	]
	
	var winner = manager.highestZIndCard(mock_results)
	assert_eq(winner, card2, "Should pick the card with the highest Z-index")

func test_stop_dragging_returns_to_hand_if_no_slot():
	var card = create_placeholder()
	var area = Area2D.new()
	area.add_child(CollisionShape2D.new())
	card.add_child(area)
	
	manager.draggingCard = card
	manager.stopDragging()
	
	assert_null(manager.draggingCard, "Dragging variable should be cleared")
