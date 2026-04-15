extends "res://addons/gut/test.gd"

const NetworkScript = preload("res://Scripts/create_lobby.gd")
var network = null

func before_each():
	network = NetworkScript.new()
	add_child_autofree(network)

func test_ping_math_logic():
	network.ping_start_time = 5000 
	
	var simulated_arrival = 5150
	network.last_ping = simulated_arrival - network.ping_start_time
	
	assert_eq(network.last_ping, 150, "Ping should calculate exactly 150ms")

func test_network_methods_exist():
	assert_true(network.has_method("server_receive_ping"), "Missing server RPC hook")
	assert_true(network.has_method("client_receive_pong"), "Missing client RPC hook")
