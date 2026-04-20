extends Node2D

const PORT = 1234
const SERVER_ADDRESS = "localhost"

var peer = ENetMultiplayerPeer.new()
var menu

@export var player_field_scene : PackedScene
@export var enemy_field_scene : PackedScene

func _ready() -> void:
	menu = $Menu
	menu.connect("host", hosting)
	menu.connect("join", joining)

func hosting():
	disable_buttons()
	
	peer.create_server(PORT)
	
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_on_peer_connected)
	
	# match start
	var player_scene = player_field_scene.instantiate()
	add_child(player_scene)
	player_scene.get_node("BattleManager").connect("game_end", game_ended)
	
	player_scene.get_node("Username").text = $Player.username
	$Menu.visible = false
	
func joining():
	disable_buttons()
	
	peer.create_client(SERVER_ADDRESS, PORT)
	
	multiplayer.multiplayer_peer = peer
	
	var player_scene = player_field_scene.instantiate()
	add_child(player_scene)
	player_scene.get_node("BattleManager").connect("game_end", game_ended)
	
	var enemy_scene = enemy_field_scene.instantiate()
	add_child(enemy_scene)
	
	player_scene.client_setup()
	$Menu.visible = false
	
func _on_peer_connected(peer_id):
	var enemy_scene = enemy_field_scene.instantiate()
	add_child(enemy_scene)
	
	get_node("PlayerField").host_setup()
	$Menu.visible = false

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

func disable_buttons():
	$Menu/StartPage.visible = false
