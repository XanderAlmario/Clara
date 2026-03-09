extends Node

const CARD_MOVE_SPEED = 0.1

var battleTimer
var emptyEnemyUnitSlots = []

# Called when the node enters the scene tree for the first time.
func _ready():
	battleTimer = $"../BattleTimer"
	battleTimer.one_shot = true
	battleTimer.wait_time = 1.0
	
	emptyEnemyUnitSlots.append($"../CardSlots/CardSlot4")
	emptyEnemyUnitSlots.append($"../CardSlots/CardSlot5")
	emptyEnemyUnitSlots.append($"../CardSlots/CardSlot6")

func _on_end_turn_button_pressed():
	enemyTurn()

func enemyTurn():
	$"../EndTurnButton".disabled = true
	$"../EndTurnButton".visible = false
	
	# Wait 1 second
	battleTimer.start()
	await battleTimer.timeout
	
	if $"../EnemyDeck".enemy_deck.size() != 0:
		$"../EnemyDeck".drawCard() 
		battleTimer.start()
		await battleTimer.timeout
	
	# Check if free unit slots, and if none, end turn
	if emptyEnemyUnitSlots.size() == 0:
		endEnemyTurn()
		return
	
	# Play card in hand with highest attack
	await playStrongestUnit()
	
	endEnemyTurn()	
	
func playStrongestUnit():
	var enemyHand = $"../EnemyHand".enemyHand
	if enemyHand.size() == 0:
		endEnemyTurn()
		return
	# Get random empty slot
	var randomEmptySlot = emptyEnemyUnitSlots[randi_range(0, emptyEnemyUnitSlots.size() - 1)]
	emptyEnemyUnitSlots.erase(randomEmptySlot)
	# Pick card with highest attack
	var strongestUnit = enemyHand[0]
	for card in enemyHand:
		if card.get_node("Attack").text > strongestUnit.get_node("Attack").text:
			strongestUnit = card
	# Animate card to slot
	var tween = get_tree().create_tween()
	tween.tween_property(strongestUnit, "position", randomEmptySlot.position, CARD_MOVE_SPEED)
	strongestUnit.get_node("AnimationPlayer").play("cardFlip")
	# Remove card from hand
	$"../EnemyHand".removeCard(strongestUnit)
	
	battleTimer.start()
	await battleTimer.timeout

func endEnemyTurn():
	$"../Deck".resetDraw()
	# Reset player deck draw
	$"../EndTurnButton".visible = true
	$"../EndTurnButton".disabled = false
