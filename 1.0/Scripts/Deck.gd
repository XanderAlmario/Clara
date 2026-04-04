extends Node2D

const CARD_SCENE_PATH = "res://Scenes/Card.tscn"
const DRAW_SPEED = 0.5
const STARTING_HAND_SIZE = 5

var player_deck = ["Knight", "Archer", "Demon", 
"Knight", "Archer", "Demon", 
"Knight", "Archer", "Demon", 
"Knight", "Archer", "Demon"]
var cardDBRef
var drewCard = false
var deck_timer

# Called when the node enters the scene tree for the first time.
func _ready():
	player_deck.shuffle()
	#$RichTextLabel.text = str(player_deck.size())
	cardDBRef = preload("res://Scripts/CardDatabase.gd")
	deck_timer = $DeckTimer
	deck_timer.one_shot = true
	deck_timer.wait_time = 1.0

func draw_initial_hand():
	deck_timer.start()
	await deck_timer.timeout
	
	deck_timer.wait_time = 0.1
	
	var player_id = multiplayer.get_unique_id()
	for i in range(STARTING_HAND_SIZE):
		draw_for_self_and_enemy(player_id)
		rpc("draw_for_self_and_enemy", player_id)
		drewCard = false
		deck_timer.start()
		await deck_timer.timeout
	drewCard = true
	
@rpc("any_peer")
func draw_for_self_and_enemy(player_id):
	if multiplayer.get_unique_id() == player_id:
		drawCard()
	else:
		get_parent().get_parent().get_node("EnemyField/EnemyDeck").drawCard()

func deckClicked():
	#if drewCard:
		#return 
	
	var player_id = multiplayer.get_unique_id()
	draw_for_self_and_enemy(player_id)
	rpc("draw_for_self_and_enemy", player_id)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func drawCard():
	drewCard = true
	var drawnCardName = player_deck[0]
	player_deck.erase(drawnCardName
	)
	
	# deck is disabled once the last card is drawn
	if player_deck.size() == 0:
		$Area2D/CollisionShape2D.disabled = true
		$Sprite2D.visible = false
		$RichTextLabel.visible = false
		
	$RichTextLabel.text = str(player_deck.size())
	var cardScene = preload(CARD_SCENE_PATH)
	var newCard = cardScene.instantiate()
	var cardImgPath = str("res://Assets/" + drawnCardName + ".png")
	newCard.get_node("CardImage").texture = load(cardImgPath)
	newCard.attack = cardDBRef.CARDS[drawnCardName][0]
	newCard.health = cardDBRef.CARDS[drawnCardName][1]
	newCard.get_node("Attack").text = str(newCard.attack)
	newCard.get_node("Health").text = str(newCard.health)
	newCard.cardType = str(cardDBRef.CARDS[drawnCardName][2])
	$"../CardManager".add_child(newCard)
	newCard.name = "Card"
	$"../PlayerHand".addCardToHand(newCard, DRAW_SPEED)
	newCard.get_node("AnimationPlayer").play("cardFlip")

func resetDraw():
	drewCard = false
