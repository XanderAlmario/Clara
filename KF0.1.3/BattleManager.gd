extends Node

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
	
	$"../EnemyDeck".drawCard()
	
	# Wait 1 second
	battleTimer.start()
	await battleTimer.timeout
	
	# Check if free unit slots, and if none, end turn
	if emptyEnemyUnitSlots.size() == 0:
		endEnemyTurn()
		return
	
	# Play card in hand with highest attack
	
	endEnemyTurn()	
	
func endEnemyTurn():
	# Reset player deck draw
	$"../EndTurnButton".visible = true
	$"../EndTurnButton".disabled = false
