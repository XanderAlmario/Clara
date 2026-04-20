extends GutTest

const PlayerHand = preload("res://scripts/PlayerHand.gd")
var hand = null

func before_each():
	hand = PlayerHand.new()
	hand.centerScreenX = 500.0 
	add_child_autofree(hand)

class FakeCard extends Node2D:
	var posInHand = Vector2(0,0)

func create_placeholder():
	return FakeCard.new()

func test_add_card():
	var card = create_placeholder()
	hand.addCardToHand(card, 0.1)
	assert_eq(hand.playerHand.size(), 1, "Card should be added to player's hand")

func test_remove_card():
	var card = create_placeholder()
	hand.addCardToHand(card, 0.1)
	hand.removeCard(card)
	assert_eq(hand.playerHand.size(), 0, "Card should be removed from player's hand")

func test_calculate_card_position():
	var card = create_placeholder()
	hand.playerHand.append(card)
	var pos = hand.calculateCardPos(0)
	var expected_center = get_viewport().size.x / 2.0
	assert_eq(pos, expected_center, "The card should be at the viewport center set by _ready()")
