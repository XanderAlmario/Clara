extends Node2D

const PORT = 1234
const SERVER_ADDRESS = "localhost"

var peer = ENetMultiplayerPeer.new()

@export var player_field_scene : PackedScene
@export var enemy_field_scene : PackedScene

func _on_host_button_pressed() -> void:
	disable_buttons()
	
	peer.create_server(PORT)
	
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_on_peer_connected)
	
	# match start
	var player_scene = player_field_scene.instantiate()
	add_child(player_scene)
	
	player_scene.get_node("Username").text = $Player.username
	
func _on_join_button_pressed() -> void:
	disable_buttons()
	
	peer.create_client(SERVER_ADDRESS, PORT)
	
	multiplayer.multiplayer_peer = peer
	
	var player_scene = player_field_scene.instantiate()
	add_child(player_scene)
	
	var enemy_scene = enemy_field_scene.instantiate()
	add_child(enemy_scene)
	
	player_scene.client_setup()
	
func _on_peer_connected(peer_id):
	var enemy_scene = enemy_field_scene.instantiate()
	add_child(enemy_scene)
	
	get_node("PlayerField").host_setup()

func _on_back_pressed():
	get_tree().change_scene_to_file("res://Scenes/username_menu.tscn")

func disable_buttons():
	$HostButton.disabled = true
	$HostButton.visible = false
	$JoinButton.disabled = true
	$JoinButton.visible = false
