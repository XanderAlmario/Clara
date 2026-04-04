extends Node2D

const CARD_SCENE_PATH = "res://Scenes/EnemyCard.tscn"
const DRAW_SPEED = 0.5
const STARTING_HAND_SIZE = 5

var enemy_deck = ["Knight", "Archer", "Demon", 
"Knight", "Archer", "Demon", 
"Knight", "Archer", "Demon", 
"Knight", "Archer", "Demon"]
var cardDBRef
var deck_size

# Called when the node enters the scene tree for the first time.
func _ready():
	enemy_deck.shuffle()
	#$RichTextLabel.text = str(enemy_deck.size())
	cardDBRef = preload("res://Scripts/CardDatabase.gd")
	#for i in range(STARTING_HAND_SIZE):
		#drawCard()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func drawCard():
	var drawnCardName = enemy_deck[0]
	enemy_deck.erase(drawnCardName)
	
	# deck is disabled once the last card is drawn
	if enemy_deck.size() == 0:
		$Sprite2D.visible = false
		$RichTextLabel.visible = false
		
	$RichTextLabel.text = str(enemy_deck.size())
	var cardScene = preload(CARD_SCENE_PATH)
	var newCard = cardScene.instantiate()
	var cardImgPath = str("res://Assets/" + drawnCardName + ".png")
	newCard.get_node("CardImage").texture = load(cardImgPath)
	newCard.attack = cardDBRef.CARDS[drawnCardName][0]
	newCard.health = cardDBRef.CARDS[drawnCardName][1]
	newCard.get_node("Attack").text = str(newCard.attack)
	newCard.get_node("Health").text = str(newCard.health)
	newCard.cardType = cardDBRef.CARDS[drawnCardName][2]
	$"../CardManager".add_child(newCard)
	newCard.name = "Card"
	$"../EnemyHand".addCardToHand(newCard, DRAW_SPEED)
