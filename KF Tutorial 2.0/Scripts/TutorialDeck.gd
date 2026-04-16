extends Node2D

const CARD_SCENE_PATH = "res://Scenes/Card.tscn"
const DRAW_SPEED = 0.5
const STARTING_HAND_SIZE = 5

var player_deck = ["Aspirant Squire", "Thaloran Lightguard", "Defender Aura", "Summon the Infantry", 
"Artimose Aetheron", "Blessed Parishioner", "Defender Aura", "Holy Crusader", 
"Blessed Crusader Hound", "Blessed Crusader Hound"]
var cardDBRef
var drewCard = false

# Called when the node enters the scene tree for the first time.
func _ready():
	#player_deck.shuffle()
	$RichTextLabel.text = str(player_deck.size())
	cardDBRef = preload("res://Scripts/CardDatabase.gd")
	for i in range(STARTING_HAND_SIZE):
		drawCard()
		drewCard = false
	drewCard = true

func drawCard():
	if drewCard:
		return 
		
	drewCard = true
	var drawnCardName = player_deck[0]
	player_deck.erase(drawnCardName)
	
	# deck is disabled once the last card is drawn
	if player_deck.size() == 0:
		$Area2D/CollisionShape2D.disabled = true
		$Sprite2D.visible = false
		$RichTextLabel.visible = false
		
	$RichTextLabel.text = str(player_deck.size())
	var cardScene = preload(CARD_SCENE_PATH)
	var newCard = cardScene.instantiate()
	var cardImgPath = str("res://Assets/" + drawnCardName + ".png")
	var cardData = cardDBRef.CARDS[drawnCardName]
	newCard.get_node("CardImage").texture = load(cardImgPath)
	
	newCard.cost = cardDBRef.CARDS[drawnCardName][0]
	newCard.cardType = str(cardDBRef.CARDS[drawnCardName][3])
	newCard.get_node("Cost").text = str(newCard.cost)
	newCard.get_node("Ability").text = str(cardDBRef.CARDS[drawnCardName][4])
	
	if newCard.cardType == "Unit":
		newCard.attack = cardDBRef.CARDS[drawnCardName][1]
		newCard.health = cardDBRef.CARDS[drawnCardName][2]
		newCard.lunge = cardDBRef.CARDS[drawnCardName][5]
		newCard.fury = cardDBRef.CARDS[drawnCardName][6]
		newCard.holyShield = cardDBRef.CARDS[drawnCardName][7]
		newCard.lifeDrain = cardDBRef.CARDS[drawnCardName][8]
		newCard.momentum = cardDBRef.CARDS[drawnCardName][9]
		newCard.fastHands = cardDBRef.CARDS[drawnCardName][10]
		newCard.get_node("Attack").text = str(newCard.attack)
		newCard.get_node("Health").text = str(newCard.health)
		newCard.spellScript = null
	else: 
		newCard.get_node("Attack").visible = false
		newCard.get_node("Health").visible = false
		if cardData.size() > 11 and cardData[11] != null:
			var script_res = load(cardData[11])
			if script_res:
				newCard.spellScript = script_res.new()
			else:
				push_error("Could not find ability script at: " + cardData[8])
				newCard.spellScript = null
		else:
			newCard.spellScript = null
	
	$"../CardManager".add_child(newCard)
	newCard.name = "Card"
	$"../TutorialPlayerHand".addCardToHand(newCard, DRAW_SPEED)
	newCard.get_node("AnimationPlayer").play("cardFlip")

func resetDraw():
	drewCard = false
