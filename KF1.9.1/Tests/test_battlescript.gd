extends GutTest

const BattleManager = preload("res://Scripts/BattleManager.gd")

class MockUnit extends Node2D:
	var health: int = 0
	var attack: int = 0
	var holyShield: bool = false
	var fury: bool = false
	var firstAttack: bool = false
	var posInBF: Vector2 = Vector2.ZERO
	var lifeDrain: bool = false
	var dead: bool = false
	var cardSlot = null

var root: Node = null
var bm: Node = null
var player_field: Node = null
var enemy_field: Node = null
var player_cm: Node = null
var enemy_cm: Node = null

func before_each():
	root = Node.new()
	root.name = "Main"
	
	enemy_field = Node.new()
	enemy_field.name = "EnemyField"
	root.add_child(enemy_field)
	
	var enemy_hp = Label.new()
	enemy_hp.name = "EnemyHP"
	enemy_field.add_child(enemy_hp)
	
	enemy_cm = Node.new()
	enemy_cm.name = "CardManager"
	enemy_field.add_child(enemy_cm)
	
	var e_grave = Node2D.new()
	e_grave.name = "EnemyGrave"
	enemy_field.add_child(e_grave)

	player_field = Node.new()
	player_field.name = "PlayerField"
	root.add_child(player_field)
	
	var p_div = Node.new()
	p_div.name = "PlayerDiv"
	player_field.add_child(p_div)
	
	var p_dev = Label.new()
	p_dev.name = "PlayerDev"
	p_div.add_child(p_dev)
	
	var p_max_dev = Label.new()
	p_max_dev.name = "PlayerMaxDev"
	p_div.add_child(p_max_dev)

	var p_bf = Node2D.new()
	p_bf.name = "PlayerBattlefield"
	player_field.add_child(p_bf)
	
	player_cm = Node.new()
	player_cm.name = "CardManager"
	var cm_script = GDScript.new()
	cm_script.source_code = "extends Node\nvar selectedUnit = null\nfunc unselect(): pass"
	cm_script.reload()
	player_cm.set_script(cm_script)
	player_field.add_child(player_cm)
	
	var p_hp_label = Label.new()
	p_hp_label.name = "PlayerHP"
	player_field.add_child(p_hp_label)
	
	var timer = Timer.new()
	timer.name = "BattleTimer"
	player_field.add_child(timer)
	
	var btn = Button.new()
	btn.name = "EndTurnButton"
	player_field.add_child(btn)

	bm = BattleManager.new()
	bm.playerHP = 10
	bm.enemyHP = 10
	player_field.add_child(bm) 
	
	bm.playerBF = p_bf
	bm.enemyBF = Node2D.new() 
	
	add_child_autofree(root)

func create_mock_unit(hp: int, atk: int, unit_name: String, keywords: Dictionary = {}):
	var unit = MockUnit.new()
	unit.name = unit_name
	unit.health = hp
	unit.attack = atk
	
	var hp_label = Label.new()
	hp_label.name = "Health"
	unit.add_child(hp_label)
	
	for key in keywords:
		unit.set(key, keywords[key])
	return unit

func test_direct_attack_updates_hp():
	var attacker = create_mock_unit(5, 4, "Attacker1")
	player_cm.add_child(attacker)
	bm.enemyHP = 10
	await bm.directAttack(attacker)
	
	assert_eq(bm.enemyHP, 6, "Enemy HP should be 10 - 4 = 6")

func test_holy_shield_logic():
	var attacker = create_mock_unit(5, 3, "AttackerShield")
	var target = create_mock_unit(5, 2, "TargetShield", {"holyShield": true})
	
	player_cm.add_child(attacker)
	enemy_cm.add_child(target)
	
	await bm.unitAttack(attacker, target)
	
	assert_eq(target.health, 5, "Shield should have prevented damage")
	
	assert_false(target.holyShield, "Shield should be spent")
