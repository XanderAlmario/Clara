extends Control

#var select_scene: PackedScene = preload("res://Scenes/hero_select.tscn")
var host
var ping_start_time = 0
var last_ping = 0

@export var player_field_scene : PackedScene
@export var enemy_field_scene : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func _on_start_button_pressed():
	#var next_scene = select_scene.instantiate()
	#var next_scene_player = next_scene.get_node("Player")
	#next_scene_player.change_username(player.username)
	#next_scene_player.choose_champion(player.champion)
	#self.get_parent().add_child(next_scene)
	#self.queue_free()
	
	var player_id = multiplayer.get_unique_id()
	
	var player_scene = player_field_scene.instantiate()
	get_parent().get_parent().add_child(player_scene)
	
	var enemy_scene = enemy_field_scene.instantiate()
	get_parent().get_parent().add_child(enemy_scene)
	
	if host == player_id:
		if player_scene.has_method("host_setup"):
			player_scene.host_setup()
	else:
		if player_scene.has_method("client_setup"):
			player_scene.client_setup()

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/lobby_create_join.tscn")

func start_ping_test():
	ping_start_time = Time.get_ticks_msec()
	rpc_id(1, "server_receive_ping")

@rpc("any_peer")
func server_receive_ping():
	var sender_id = multiplayer.get_remote_sender_id()
	rpc_id(sender_id, "client_receive_pong")

@rpc("any_peer")
func client_receive_pong():
	last_ping = Time.get_ticks_msec() - ping_start_time
	print("Ping: %d ms" % last_ping)
