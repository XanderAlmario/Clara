extends Node2D

const CARD_SCENE_PATH = "res://Scenes/Card.tscn"
const DRAW_SPEED = 0.5
const STARTING_HAND_SIZE = 5

var player_deck = ["Knight", "Demon", "Leech", 
"Leech", "Ravager", "Priest", "Discovery", "Frozen Spike"]
var cardDBRef
var drewCard = false
var deck_timer

# Called when the node enters the scene tree for the first time.
func _ready():
	player_deck.shuffle()
	#$RichTextLabel.text = str(player_deck.size())
	cardDBRef = preload("res://Scripts/CardDatabase.gd")
	#for i in range(STARTING_HAND_SIZE):
		#drawCard()
		#drewCard = false
	#drewCard = true
	deck_timer = $DeckTimer
	deck_timer.one_shot = true
	deck_timer.wait_time = 1.0

func draw_initial_hand():
	deck_timer.start()
	await deck_timer.timeout
	
	deck_timer.wait_time = 0.1
	
	var player_id = multiplayer.get_unique_id()
	for i in range(STARTING_HAND_SIZE):
		var drawnCardName = player_deck[0]
		draw_for_self_and_enemy(player_id, drawnCardName)
		rpc("draw_for_self_and_enemy", player_id, drawnCardName)
		drewCard = false
		deck_timer.start()
		await deck_timer.timeout
	drewCard = true
	
@rpc("any_peer")
func draw_for_self_and_enemy(player_id, drawnCardName):
	if multiplayer.get_unique_id() == player_id:
		drawCard(drawnCardName)
	else:
		get_parent().get_parent().get_node("EnemyField/EnemyDeck").drawCard(drawnCardName)

func deckClicked():
	if drewCard:
		return
	
	var drawnCardName = player_deck[0]
	var player_id = multiplayer.get_unique_id()
	draw_for_self_and_enemy(player_id, drawnCardName)
	rpc("draw_for_self_and_enemy", player_id)

func drawCard(drawnCardName):
	drewCard = true
	player_deck.erase(drawnCardName)
	
	# deck is disabled once the last card is drawn
	if player_deck.size() == 0:
		$Area2D/CollisionShape2D.disabled = true
		visible = false
		
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
		newCard.bloated = cardDBRef.CARDS[drawnCardName][9]
		newCard.get_node("Attack").text = str(newCard.attack)
		newCard.get_node("Health").text = str(newCard.health)
		newCard.spellScript = null
	else: 
		newCard.get_node("Attack").visible = false
		newCard.get_node("Health").visible = false
		if cardData.size() > 10 and cardData[10] != null:
			var script_res = load(cardData[10])
			if script_res:
				newCard.spellScript = script_res.new()
			else:
				push_error("Could not find ability script at: " + cardData[8])
				newCard.spellScript = null
		else:
			newCard.spellScript = null
	
	$"../CardManager".add_child(newCard)
	newCard.name = "Card"
	$"../PlayerHand".addCardToHand(newCard, DRAW_SPEED)
	newCard.get_node("AnimationPlayer").play("cardFlip")

func resetDraw():
	drewCard = false
