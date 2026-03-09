extends Node2D

const CARD_WIDTH = 150
const HAND_Y_POSITION = 0
const DEFAULT_CARD_SPEED = 0.1

var enemyHand = []
var centerScreenX

func _ready():
	centerScreenX = get_viewport().size.x / 2

func addCardToHand(card, speed):
	if card not in enemyHand:
		enemyHand.insert(0, card)
		updateHandPos(speed)
	else:
		moveCardToPos(card, card.posInHand, DEFAULT_CARD_SPEED)

func updateHandPos(speed):
	for i in range(enemyHand.size()):
		var newPos = Vector2(calculateCardPos(i), HAND_Y_POSITION)
		var card = enemyHand[i]
		card.posInHand = newPos 
		moveCardToPos(card, newPos, speed)
		
func calculateCardPos(index):
	var totalWidth = (enemyHand.size() - 1) * CARD_WIDTH
	var xOffset = centerScreenX - index * CARD_WIDTH + totalWidth / 2
	return xOffset

func moveCardToPos(card, newPos, speed):
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", newPos, speed)
	
func removeCard(card):
	if card in enemyHand:
		enemyHand.erase(card)
		updateHandPos(DEFAULT_CARD_SPEED)
