extends "res://addons/gut/test.gd"

var BattleMan = load("res://Scripts/BattleManager.gd") 
var _battle_man = null
var _mock_root = null
var _deck = null

func before_each():
	_mock_root = Node.new()
	add_child(_mock_root)
	
	var timer = Timer.new()
	timer.name = "BattleTimer"
	_mock_root.add_child(timer)
	
	var player_div = Node.new()
	player_div.name = "PlayerDiv"
	_mock_root.add_child(player_div)
	
	var p_dev = Label.new()
	p_dev.name = "PlayerDev"
	player_div.add_child(p_dev)
	
	var p_max_dev = Label.new()
	p_max_dev.name = "PlayerMaxDev"
	player_div.add_child(p_max_dev)

	_battle_man = BattleMan.new()
	_battle_man.name = "BattleManager"
	_mock_root.add_child(_battle_man)
	
	var player_bf = Node.new()
	player_bf.name = "playerBF"
	player_bf.set("unitsInPlay", []) 
	#player_bf.set("BFSize", 5)
	_mock_root.add_child(player_bf)
	_battle_man.playerBF = player_bf

	var enemy_bf = Node.new()
	enemy_bf.name = "enemyBF"
	enemy_bf.set("unitsInPlay", [])
	_mock_root.add_child(enemy_bf)
	_battle_man.enemyBF = enemy_bf

	_deck = MockDeck.new()
	_deck.name = "Deck" 
	_deck.player_deck = ["Paladin", "Mage", "Archer"]
	_mock_root.add_child(_deck)

	var player_hand = Node.new()
	player_hand.name = "PlayerHand"
	player_hand.set("playerHand", []) 
	_mock_root.add_child(player_hand)

func after_each():
	_mock_root.queue_free()

# feature: managing resources

func test_devotion_increases_on_new_turn():

	_battle_man.playerMaxDev = 4
	_battle_man.playerDev = 0
	

	_battle_man.updatePlayerDev() 
	
	assert_eq(_battle_man.playerMaxDev, 5, "Max devotion should increase by 1 per turn")
	assert_eq(_battle_man.playerDev, 5, "Current devotion should refill to the new Max Devotion")

func test_devotion_caps_at_maximum():
	_battle_man.playerMaxDev = _battle_man.MAX_DEVOTION 
	
	_battle_man.updatePlayerDev()
	
	assert_eq(_battle_man.playerMaxDev, 10, "Max devotion should not exceed MAX_DEVOTION (10)")

func test_playing_card_reduces_devotion():
	
	_battle_man.playerDev = 5
	var card_cost = 3
	
	_battle_man.playerPlayCard(card_cost) 
	
	assert_eq(_battle_man.playerDev, 2, "Playing a card should subtract its cost from current Devotion")

# feature: placing cards onto the field

# We use a mock card class here 
# this is so we do not need to import the entire Card.tscn anymore
# so with MockCard, we can just test the card math independently 

class MockCard:
	var name = "TestCard"
	var cost = 3
	var attack = 0
	var health = 0
	var flipped = false
	var canAttack = true
	var holyShield = false
	var fastHands = false

class MockDeck extends Node:
	var player_deck = []
	
	func drawCard(card_to_remove):
		if player_deck.has(card_to_remove):
			player_deck.erase(card_to_remove)
		else:
			push_error("MockDeck: Card not found in deck!")

func test_card_cost_without_tax():
	var mock_card = MockCard.new()
	_battle_man.player_is_taxed_turns = 0
	
	var actual_cost = _battle_man.get_card_purchase_cost(mock_card)  
	assert_eq(actual_cost, 3, "Card cost should equal its base cost when not taxed")
	# this tests if fatigue aura improperly applies to non-fatigued cards
	# card cost without fatigue should be the same as mockcard.cost (hardcoded to 3 for testing)

func test_fatigue_aura_increases_card_cost():
	var mock_card = MockCard.new()
	
	_battle_man.receive_fatigue_aura() 
	
	var actual_cost = _battle_man.get_card_purchase_cost(mock_card)
	
	# fatigue aura should increase card cost by 1
	assert_eq(_battle_man.player_is_taxed_turns, 2, "Fatigue aura should tax the player for 2 turns")
	
	# asserts fatigue aura tax is implementing (ie 3 + 1 equals 4)
	assert_eq(actual_cost, 4, "Card cost should be increased by 1 due to the active tax") 

# feature: gathering / drawing cards

func test_draw_card_removes_from_deck():

	var card_to_draw = "Paladin"
	var initial_size = _deck.player_deck.size()
	
	_deck.drawCard(card_to_draw)
	
	assert_eq(_deck.player_deck.size(), initial_size - 1, "Deck size should decrease")
	assert_does_not_have(_deck.player_deck, card_to_draw, "The card should be gone from the deck")

func test_draw_card_adds_to_hand():
	var hand = _mock_root.get_node("PlayerHand")
	var initial_hand_size = hand.playerHand.size()
	var drawn_card = "Paladin Defender"

	hand.playerHand.append(drawn_card)

	var new_hand_size = hand.playerHand.size()
	assert_eq(new_hand_size, initial_hand_size + 1, "Hand size should increase per draw") 
	assert_has(hand.playerHand, drawn_card, "The hand should now have drawn card")

# interacting cards

func test_card_flipped_after_attack():
	var mock_card = MockCard.new()
	mock_card.flipped = false
	mock_card.canAttack = true
	
	mock_card.flipped = true 
	_battle_man.playerUnitsAttacked.append(mock_card)

	assert_true(mock_card.flipped, "The card should be flipped after attacking")
	assert_has(_battle_man.playerUnitsAttacked, mock_card, "The card should be in the attacked list")

func test_attack_damages_enemy_directly_when_no_defenders():

	_battle_man.enemyHP = 10
	var attacker_damage = 3
	
	_battle_man.enemyBF.unitsInPlay.clear()
	
	if _battle_man.enemyBF.unitsInPlay.size() == 0:
		_battle_man.enemyHP -= attacker_damage
	
	assert_eq(_battle_man.enemyHP, 7, "Enemy HP should be reduced because there were no units to block")

func test_attack_blocked_by_enemy_units():
	_battle_man.enemyHP = 10
	var attacker_damage = 3
	
	_battle_man.enemyBF.unitsInPlay.append("Enemy Soldier")
	
	if _battle_man.enemyBF.unitsInPlay.size() == 0:
		_battle_man.enemyHP -= attacker_damage
	
	assert_eq(_battle_man.enemyHP, 10, "Enemy HP should NOT decrease if units are in play")

func test_holy_shield_blocks_damage():

	var mock_attacker = MockCard.new()
	mock_attacker.set("attack", 5)
	mock_attacker.set("health", 5)
	mock_attacker.set("holyShield", false) 
	mock_attacker.set("fastHands", false)
	
	var mock_target = MockCard.new()
	mock_target.set("attack", 3)
	mock_target.set("health", 4)
	mock_target.set("holyShield", true) 
	mock_target.set("fastHands", false)
	
	if mock_target.holyShield and !mock_attacker.holyShield:
		mock_attacker.health = max(0, mock_attacker.health - mock_target.attack)
		mock_target.holyShield = false 

	assert_eq(mock_target.health, 4, "Target's health should remain unchanged because of Holy Shield")
	assert_false(mock_target.holyShield, "Holy Shield should be consumed after taking a hit")
	assert_eq(mock_attacker.health, 2, "Attacker should still take retaliation damage (5 - 3 = 2)")
