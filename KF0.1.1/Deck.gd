extends Node2D

const CARD_SCENE_PATH = "res://Scenes/Card.tscn"
const DRAW_SPEED = 1

var player_deck = ["Knight", "Knight", "Knight"]

# Called when the node enters the scene tree for the first time.
func _ready():
	$RichTextLabel.text = str(player_deck.size())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func drawCard():
	var drawn_card = player_deck[0]
	player_deck.erase(drawn_card)
	
	# deck is disabled once the last card is drawn
	if player_deck.size() == 0:
		$Area2D/CollisionShape2D.disabled = true
		$Sprite2D.visible = false
		$RichTextLabel.visible = false
		
	$RichTextLabel.text = str(player_deck.size())
	var cardScene = preload(CARD_SCENE_PATH)
	var newCard = cardScene.instantiate()
	$"../CardManager".add_child(newCard)
	newCard.name = "Card"
	$"../PlayerHand".addCardToHand(newCard, DRAW_SPEED)
