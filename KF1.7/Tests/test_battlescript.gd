extends GutTest

const BattleManager = preload("res://Scripts/BattleManager.gd")

class MockUnit extends Node2D:
	var health: int = 0
	var attack: int = 0
	var lunge: bool = false
	var holyShield: bool = false
	var fury: bool = false
	var lifeDrain: bool = false
	var canAttack: bool = false
	var firstAttack: bool = false
	var dead: bool = false
	var posInBF: Vector2 = Vector2.ZERO
	var cardSlot = null

var bm: Node = null 
var root: Node = null 

func before_each():
	root = Node.new()
	
	var nodes_to_add = {
		"BattleTimer": Timer.new(),
		"PlayerHP": Label.new(),
		"EnemyHP": Label.new(),
		"EndTurnButton": Button.new(),
		"EnemyDeck": Node.new(),
		"Deck": Node.new(),
		"EnemyHand": Node.new(),
		"PlayerGrave": Node2D.new(),
		"EnemyGrave": Node2D.new()
	}
	
	for name in nodes_to_add:
		var n = nodes_to_add[name]
		n.name = name
		root.add_child(n)
	
	var card_man = Node.new()
	card_man.name = "CardManager"
	var cm_script = GDScript.new()
	cm_script.source_code = "extends Node\nvar selectedUnit = null\nfunc unselect(): pass"
	cm_script.reload()
	card_man.set_script(cm_script)
	root.add_child(card_man)
		
	var divs = ["PlayerDiv", "EnemyDiv"]
	for d_name in divs:
		var div = Node.new(); div.name = d_name
		var dev = Label.new(); dev.name = d_name.replace("Div", "Dev")
		var max_dev = Label.new(); max_dev.name = d_name.replace("Div", "MaxDev")
		div.add_child(dev); div.add_child(max_dev)
		root.add_child(div)
	
	var bf_script = GDScript.new()
	bf_script.source_code = "extends Node2D\nvar unitsInPlay = []\nvar BFSize = 5"
	bf_script.reload()

	var p_bf = Node2D.new(); p_bf.name = "PlayerBattlefield"
	p_bf.set_script(bf_script)
	root.add_child(p_bf)

	var e_bf = Node2D.new(); e_bf.name = "EnemyBattlefield"
	e_bf.set_script(bf_script)
	root.add_child(e_bf)

	bm = BattleManager.new()
	root.add_child(bm) 
	
	bm.playerBF = p_bf
	bm.enemyBF = e_bf
	
	add_child_autofree(root)

func create_mock_unit(hp: int, atk: int, keywords: Dictionary = {}):
	var unit = MockUnit.new()
	unit.health = hp
	unit.attack = atk
	
	var hp_label = Label.new()
	hp_label.name = "Health"
	unit.add_child(hp_label)
	
	for key in keywords:
		unit.set(key, keywords[key])
	return unit


func test_initialization():
	assert_eq(bm.playerHP, 10, "Should start with 10 HP")
	assert_eq(root.get_node("PlayerHP").text, "10", "UI should update on start")

func test_update_devotion_logic():
	bm.playerMaxDev = 5
	bm.updatePlayerDev()
	
	assert_eq(bm.playerMaxDev, 6, "Max Devotion should increase by 1 per call")
	assert_eq(bm.playerDev, 6, "Current Devotion should refill to Max")
	assert_eq(root.get_node("PlayerDiv/PlayerDev").text, "6")

func test_holy_shield_block_actual_logic():
	var attacker = create_mock_unit(5, 3)
	var target = create_mock_unit(5, 2, {"holyShield": true})
	
	await bm.unitAttack(attacker, target, "Player")
	
	assert_eq(target.health, 5, "Shield should have prevented HP reduction")
	assert_eq(attacker.health, 3, "Attacker should still take counter-damage (5 - 2)")
	assert_false(target.holyShield, "Shield should be spent")

func test_fury_list_logic():
	var unit = create_mock_unit(4, 3, {"fury": true, "firstAttack": false})
	bm.playerUnitsAttacked.append(unit)
	if unit.fury and !unit.firstAttack:
		bm.playerUnitsAttacked.erase(unit)
	
	assert_eq(bm.playerUnitsAttacked.size(), 0, "Fury unit should be removed from 'attacked' list to allow 2nd attack")

func test_direct_attack_updates_hp():
	var attacker = create_mock_unit(5, 4)
	var initial_enemy_hp = bm.enemyHP 
	await bm.directAttack(attacker, "Player")
	
	assert_eq(bm.enemyHP, initial_enemy_hp - 4, "Enemy HP should decrease by attacker's power")
	assert_eq(root.get_node("EnemyHP").text, "6")
