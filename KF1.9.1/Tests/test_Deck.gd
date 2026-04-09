extends GutTest

const DeckScript = preload("res://Scripts/Deck.gd")
const CARD_SCENE_PATH = "res://Scenes/Card.tscn"

var prototype_deck = null
var prototype_hand = null
var prototype_manager = null

func before_each():
	var root = Node2D.new()
	add_child_autofree(root)
	
	prototype_manager = Node2D.new()
	prototype_manager.name = "CardManager"
	var prototype_script = GDScript.new()
	prototype_script.source_code = "extends Node2D\nfunc connectSignals(card):\n    pass"
	prototype_script.reload()
	prototype_manager.set_script(prototype_script)
	root.add_child(prototype_manager)
	
	prototype_hand = Node2D.new()
	prototype_hand.name = "PlayerHand"
	prototype_hand.set_script(load("res://Scripts/PlayerHand.gd")) 
	root.add_child(prototype_hand)
	prototype_deck = DeckScript.new()
	
	var timer = Timer.new()
	timer.name = "DeckTimer"
	prototype_deck.add_child(timer)
	
	var prototype_card_node = Node2D.new()
	prototype_card_node.name = "Card"
	
	var img = Sprite2D.new()
	img.name = "CardImage"
	prototype_card_node.add_child(img)
	
	var atk = Label.new()
	atk.name = "Attack"
	prototype_card_node.add_child(atk)
	
	var hp = Label.new()
	hp.name = "Health"
	prototype_card_node.add_child(hp)
	
	var anim = AnimationPlayer.new()
	anim.name = "AnimationPlayer"
	prototype_card_node.add_child(anim)
	
	
	var label = RichTextLabel.new()
	label.name = "RichTextLabel"
	prototype_deck.add_child(label)
	
	var area = Area2D.new()
	area.name = "Area2D"
	prototype_deck.add_child(area)
	
	var col = CollisionShape2D.new()
	col.name = "CollisionShape2D"
	area.add_child(col)
	
	var sprite = Sprite2D.new()
	sprite.name = "Sprite2D"
	prototype_deck.add_child(sprite)
	
	var cost = Label.new()
	cost.name = "Cost"
	prototype_card_node.add_child(cost)

	var ability = Label.new()
	ability.name = "Ability"
	prototype_card_node.add_child(ability)
	
	root.add_child(prototype_deck)
	
func test_draw_card_removes_from_deck():
	var initial_deck_size = prototype_deck.player_deck.size()
	prototype_deck.resetDraw() 
	
	var card_to_draw = prototype_deck.player_deck[0]
	prototype_deck.drawCard(card_to_draw)
	
	assert_eq(prototype_deck.player_deck.size(), initial_deck_size - 1, "Deck size should be decreased by 1")
	
func test_deck_disabled_when_empty():
	prototype_deck.player_deck = ["Knight"]
	prototype_deck.resetDraw()
	prototype_deck.drawCard("Knight")
	
	assert_true(prototype_deck.get_node("Area2D/CollisionShape2D").disabled)
	
func test_card_added_to_manager():
	prototype_deck.resetDraw()
	prototype_deck.drawCard("Knight")
	
	var card = prototype_manager.get_node_or_null("Card")
	assert_not_null(card, "A card node should be instantiated in CardManager")
	
func load_ability(script_path: String):
	if script_path == "":
		push_error("Ability path is empty!")
		return null
	var script_resource = load(script_path)
	if script_resource:
		return script_resource.new()
	else:
		push_error("Failed to load script at: " + script_path)
		return null

func trigger_ability(_deck_manager, battle_manager):
	var enemies = battle_manager.enemyUnitsOnBF
	if enemies.size() > 0:
		var target = enemies[randi() % enemies.size()]
		var damage = 2
		if "health" in target:
			target.health -= damage
			if target.has_node("Health"):
				target.get_node("Health").text = str(target.health)
			if target.health <= 0:
				battle_manager.destroyCard(target, "enemy")
		else:
			push_error("Frozen Spike hit an invalid target (no health property): " + target.name)
	else:
		print("No enemies to target.")
