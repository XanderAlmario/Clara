extends Node2D

const PORT = 1234
const SERVER_ADDRESS = "localhost"

var player
var opponent
var peer = ENetMultiplayerPeer.new()
var menu
var lobby_page
var host = false

@export var player_field_scene : PackedScene
@export var enemy_field_scene : PackedScene

func _ready() -> void:
	player = $Player
	opponent = $Opponent
	menu = $Menu
	menu.connect("host", hosting)
	menu.connect("join", joining)
	#menu.connect("game_start", starting)
	lobby_page = menu.get_node("LobbyPage")

func start_game(is_host):
	start_game_for_everyone(is_host)
	rpc("start_game_for_everyone", is_host)
	
@rpc("authority")
func start_game_for_everyone(is_host):
	var player_scene = player_field_scene.instantiate()
	add_child(player_scene)
	player_scene.get_node("BattleManager").connect("game_end", game_ended)
	
	var enemy_scene = enemy_field_scene.instantiate()
	add_child(enemy_scene)
	
	if multiplayer.is_server():
		player_scene.host_setup()
	else:
		player_scene.client_setup()
	
	player_scene.get_node("Username").text = player.username
	enemy_scene.get_node("Username").text = opponent.username
	
	$Menu.visible = false

func hosting():
	peer.create_server(PORT)
	
	host = true
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_on_peer_connected)
	
	# to lobby
	menu.redirect("Lobby")
	lobby_page.host_lobby()
	
	lobby_page.connect("start_game", start_game)
	
func joining():
	peer.create_client(SERVER_ADDRESS, PORT)
	
	host = false
	multiplayer.multiplayer_peer = peer
	multiplayer.connected_to_server.connect(func():
		rpc_id(1, "sync_usernames", player.username)
	)
	
	# to lobby
	menu.redirect("Lobby")
	lobby_page.join_lobby()
	
func _on_peer_connected(peer_id):
	rpc_id(peer_id, "sync_usernames", player.username)
	lobby_page.on_join_lobby()

@rpc("any_peer")
func sync_usernames(username):
	var sender_id = multiplayer.get_remote_sender_id()
	
	if sender_id == multiplayer.get_unique_id():
		return # ignore self
	
	opponent.change_username(username)
	lobby_page.update_opponent_username(host, username)

func game_ended(win : bool):
	if win:
		$Menu.get_node("MatchSummaryPage/Panel/ResultLabel").text = "YOU WIN!"
	else:
		$Menu.get_node("MatchSummaryPage/Panel/ResultLabel").text = "YOU LOSE!"
	$PlayerField.queue_free()
	$EnemyField.queue_free()
	$Menu.redirect("MatchSummary")
	$Menu.visible = true
	
	if multiplayer.multiplayer_peer:
		multiplayer.multiplayer_peer.close()
		multiplayer.multiplayer_peer = null
		
	peer = ENetMultiplayerPeer.new()
