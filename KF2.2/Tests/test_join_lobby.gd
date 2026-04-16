extends "res://addons/gut/test.gd"

var JoinMenu = load("res://Scenes/join_lobby.tscn")
var _menu = null

func before_each():
	_menu = JoinMenu.instantiate()
	add_child(_menu)

func after_each():
	_menu.queue_free()
	
func test_back_button_exists():
	var button = _menu.get_node("BackButton")
	assert_not_null(button, "back button should exist")
	assert_connected(button, _menu, "pressed", "_on_back_button_pressed")
	
func test_on_back_button_pressed_logic():
	_menu._on_back_button_pressed()
	pass_test("test passed") # test passes if this line is reached
	
