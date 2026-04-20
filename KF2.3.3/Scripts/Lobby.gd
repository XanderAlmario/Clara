extends Control

var menu
var player
var opponent
var lobby
var characters

func _ready() -> void:
	menu = get_parent()
	player = $"../../Player"
	opponent = $"../../Opponent"
	lobby = $Lobby
	characters = $Characters

func _on_paladin_button_pressed() -> void:
	pass # Replace with function body.

func _on_monk_button_pressed() -> void:
	pass # Replace with function body.

func hosting():
	lobby.get_node("PlayerContainer/UsernameLabel").text = player.username
	player.change_champion = lobby.get_node("PlayerContainer/CharacterLabel").text 

@rpc("any_peer")
func choose_champ(panel, is_player : bool):
	var char_name = panel.get_node("CharacterLabel").text
	var char_class = panel.get_node("CharacterClass").text
	
	if is_player:
		lobby.get_node("PlayerContainer/CharacterLabel").text = char_name
	else:
		lobby.get_node("OpponentContainer/CharacterLabel").text = char_name
	
