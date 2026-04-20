extends Control

signal start_game

var menu
var player
var opponent
var lobby
var characters
var inh_host

func _ready() -> void:
	menu = get_parent()
	player = $"../../Player"
	opponent = $"../../Opponent"
	lobby = $Lobby
	characters = $Characters

func _on_paladin_button_pressed() -> void:
	characters.get_node("Paladin/PaladinButton").modulate = Color(1.0, 1.0, 1.0, 1.0)
	characters.get_node("Monk/MonkButton").modulate = Color(1.0, 1.0, 1.0, 0.0)
	
	var my_id = multiplayer.get_unique_id()
	var paladin_name = characters.get_node("Paladin/CharacterLabel").text
	
	choose_champ(my_id, paladin_name)
	rpc("choose_champ", my_id, paladin_name)

func _on_monk_button_pressed() -> void:
	characters.get_node("Paladin/PaladinButton").modulate = Color(1.0, 1.0, 1.0, 0.0)
	characters.get_node("Monk/MonkButton").modulate = Color(1.0, 1.0, 1.0, 1.0)
	
	var my_id = multiplayer.get_unique_id()
	var monk_name = characters.get_node("Monk/CharacterLabel").text
	
	choose_champ(my_id, monk_name)
	rpc("choose_champ", my_id, monk_name)

func host_lobby():
	characters.get_node("Paladin/PaladinButton").modulate = Color(1.0, 1.0, 1.0, 1.0)
	characters.get_node("Monk/MonkButton").modulate = Color(1.0, 1.0, 1.0, 0.0)
	
	lobby.get_node("PlayerContainer/UsernameLabel").text = player.username
	player.choose_champion(lobby.get_node("PlayerContainer/CharacterLabel").text)
	
func join_lobby(): # note that the joining player is the opponent here
	characters.get_node("Paladin/PaladinButton").modulate = Color(1.0, 1.0, 1.0, 0.0)
	characters.get_node("Monk/MonkButton").modulate = Color(1.0, 1.0, 1.0, 1.0)
	
	lobby.get_node("PlayerContainer/UsernameLabel").text = opponent.username
	opponent.choose_champion(lobby.get_node("PlayerContainer/CharacterLabel").text)
	
	lobby.get_node("OpponentContainer").visible = true
	lobby.get_node("OpponentContainer/UsernameLabel").text = player.username
	player.choose_champion(lobby.get_node("OpponentContainer/CharacterLabel").text)

func on_join_lobby():
	lobby.get_node("OpponentContainer").visible = true
	lobby.get_node("OpponentContainer/UsernameLabel").text = opponent.username
	opponent.choose_champion(lobby.get_node("OpponentContainer/CharacterLabel").text)
	
	$StartGameButton.disabled = false

func update_opponent_username(host, name):
	inh_host = host
	
	if host:
		lobby.get_node("OpponentContainer/UsernameLabel").text = name
	else:
		lobby.get_node("PlayerContainer/UsernameLabel").text = name

@rpc("any_peer")
func choose_champ(player_id, char_name):
	if multiplayer.get_unique_id() == player_id:
		if inh_host:
			player.choose_champion(char_name)
			lobby.get_node("PlayerContainer/CharacterLabel").text = char_name
		else:
			player.choose_champion(char_name)
			lobby.get_node("OpponentContainer/CharacterLabel").text = char_name
	else:
		if inh_host:
			opponent.choose_champion(char_name)
			lobby.get_node("OpponentContainer/CharacterLabel").text = char_name
		else:
			opponent.choose_champion(char_name)
			lobby.get_node("PlayerContainer/CharacterLabel").text = char_name

func _on_start_game_button_pressed() -> void:
	emit_signal("start_game", inh_host)
