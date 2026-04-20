extends "res://addons/gut/test.gd"

var LobbyMenu = load("res://Scenes/lobby_create_join.tscn")
var _menu = null

func before_each():
	_menu = LobbyMenu.instantiate()
	add_child(_menu)

func after_each():
	_menu.queue_free()
	
func test_create_button_exists():
	var button = _menu.get_node("VBoxContainer/CreateButton")
	assert_not_null(button, "create button should exist")
	assert_connected(button, _menu, "pressed", "_on_create_button_pressed")
	
func test_join_button_exists():
	var button = _menu.get_node("VBoxContainer/JoinButton")
	assert_not_null(button, "join button should exist")
	assert_connected(button, _menu, "pressed", "_on_join_button_pressed")
	
func test_on_create_button_pressed_logic():
	assert_file_exists("res://Scenes/create_lobby.tscn")
	_menu._on_create_button_pressed()
	pass_test("test passed") # test passes if this line is reached
	
func test_on_join_button_pressed_logic():
	assert_file_exists("res://Scenes/join_lobby.tscn")
	_menu._on_join_button_pressed()
	pass_test("test passed") # test passes if this line is reached
	
