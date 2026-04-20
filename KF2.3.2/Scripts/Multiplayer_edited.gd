extends Node2D

const PORT = 1234
const SERVER_ADDRESS = "localhost"

var peer = ENetMultiplayerPeer.new()
var plr
var opp

var create_scene: PackedScene = preload("res://Scenes/create_lobby.tscn")
var join_scene: PackedScene = preload("res://Scenes/join_lobby.tscn")

func _ready():
	plr = get_parent().get_node("Player")
	opp = get_parent().get_node("Opponent")

func _on_host_button_pressed() -> void:
	disable_buttons()
	
	peer.create_server(PORT)
	
	multiplayer.multiplayer_peer = peer
	
	multiplayer.peer_connected.connect(_on_peer_connected)
	
	var lobby = create_scene.instantiate()
	add_child(lobby)
	lobby.get_node("Player").change_username($Player.username)
	lobby.get_node("Player").choose_champion($Player.champion)
	
	# match start
	#var player_scene = player_field_scene.instantiate()
	#add_child(player_scene)
	#
	#player_scene.get_node("Username").text = $Player.username
	
func _on_join_button_pressed() -> void:
	#disable_buttons()
	
	peer.create_client(SERVER_ADDRESS, PORT)
	
	multiplayer.multiplayer_peer = peer
	
	var lobby = create_scene.instantiate()
	add_child(lobby)
	lobby.get_node("StatusLabel").text = plr.username
	lobby.get_node("StartButton").disabled = true
	
	var player_id = multiplayer.get_unique_id
	pass_username(player_id, plr.username)
	rpc("pass_username", player_id, plr.username)
	
	#var player_scene = player_field_scene.instantiate()
	#add_child(player_scene)
	#
	#var enemy_scene = enemy_field_scene.instantiate()
	#add_child(enemy_scene)
	#
	#player_scene.client_setup()
	
@rpc("any_peer")
func pass_username(player_id, name):
	if multiplayer.get_unique_id != player_id:
		opp.set_username(name)
		var lobby = get_node("CreateLobby")
		lobby.host = player_id
	
func _on_peer_connected(peer_id):
	var lobby = get_node("CreateLobby")
	lobby.StatusLabel = opp.username
	
	#var enemy_scene = enemy_field_scene.instantiate()
	#add_child(enemy_scene)
	#
	#get_node("PlayerField").host_setup()

func _on_back_pressed():
	get_tree().change_scene_to_file("res://Scenes/username_menu.tscn")

func disable_buttons():
	$HostButton.disabled = true
	$HostButton.visible = false
	$JoinButton.disabled = true
	$JoinButton.visible = false
