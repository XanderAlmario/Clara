extends "res://addons/gut/test.gd"

var CreateMenu = load("res://Scenes/create_lobby.tscn")
var _menu = null

func before_each():
	var mock_grandparent = Node.new()
	var mock_parent = Node.new()
	_menu = CreateMenu.instantiate()
	
	mock_grandparent.add_child(mock_parent)
	mock_parent.add_child(_menu)
	add_child_autofree(mock_grandparent)

func after_each():
	_menu.queue_free()
	
func test_start_button_exists():
	var button = _menu.get_node("StartButton")
	assert_not_null(button, "start button should exist")
	assert_connected(button, _menu, "pressed", "_on_start_button_pressed")
	
func test_back_button_exists():
	var button = _menu.get_node("BackButton")
	assert_not_null(button, "back button should exist")
	assert_connected(button, _menu, "pressed", "_on_back_button_pressed")
	
func test_on_start_button_pressed_logic():
	var p_field = load("res://Scenes/Battlefield.tscn")
	var e_field = load("res://Scenes/EnemyField.tscn")
	
	assert_not_null(p_field, "Battlefield scene should exist")
	
	_menu.player_field_scene = p_field
	_menu.enemy_field_scene = e_field

	_menu.host = multiplayer.get_unique_id() 
	
	_menu._on_start_button_pressed()
	pass_test("Reached end of logic without crashing")
	
func test_on_back_button_pressed_logic():
	_menu._on_back_button_pressed()
	pass_test("test passed") # test passes if this line is reached
	
