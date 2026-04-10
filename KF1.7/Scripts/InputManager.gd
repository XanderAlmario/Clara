extends Node2D

signal onClick
signal clickReleased

const COLLISION_MASK_CARD = 1
const COLLISION_MASK_DECK = 4
const COLLISION_MASK_ENEMY_CARD = 8

var card_manager_reference
var deck_reference

func _ready() -> void:
	card_manager_reference = $"../CardManager"
	deck_reference = $"../Deck"

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			emit_signal("onClick")
			cursorOnCard()
		else:
			emit_signal("clickReleased")

func cursorOnCard():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	var result = space_state.intersect_point(parameters)
	if (result.size() > 0):
		var result_collision_mask = result[0].collider.collision_mask
		var index
		for i in result.size():
			if result[i].collider.collision_mask == COLLISION_MASK_CARD:
				result_collision_mask = result[i].collider.collision_mask
				index = i
				break
		if result_collision_mask == COLLISION_MASK_CARD:
			#if the card is selected
			var card_found = result[index].collider.get_parent()
			if card_found: 
				card_manager_reference.cardClicked(card_found)
		elif result_collision_mask == COLLISION_MASK_ENEMY_CARD:
			$"../BattleManager".enemyCardSelected(result[0].collider.get_parent())
	
