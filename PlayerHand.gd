extends Node2D

const HAND_COUNT = 5
const CARD_SCENE_PATH = "res://Scenes/Card.tscn"
const CARD_WIDTH = 150
const HAND_Y_POSITION = 1050

var playerHand = []
var centerScreenX

func _ready():
	centerScreenX = get_viewport().size.x / 2
	
	var cardScene = preload(CARD_SCENE_PATH)
	for i in range(HAND_COUNT):
		var newCard = cardScene.instantiate()
		$"../CardManager".add_child(newCard)
		newCard.name = "Card"
		addCardToHand(newCard)

func addCardToHand(card):
	if card not in playerHand:
		playerHand.insert(0, card)
		updateHandPos()
	else:
		moveCardToPos(card, card.posInHand)

func updateHandPos():
	for i in range(playerHand.size()):
		var newPos = Vector2(calculateCardPos(i), HAND_Y_POSITION)
		var card = playerHand[i]
		card.posInHand = newPos 
		moveCardToPos(card, newPos)
		
func calculateCardPos(index):
	var totalWidth = (playerHand.size() - 1) * CARD_WIDTH
	var xOffset = centerScreenX + index * CARD_WIDTH - totalWidth / 2
	return xOffset

func moveCardToPos(card, newPos):
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", newPos, 0.1)
	
func removeCard(card):
	if card in playerHand:
		playerHand.erase(card)
		updateHandPos()
