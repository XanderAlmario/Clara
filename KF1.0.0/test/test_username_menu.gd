extends "res://addons/gut/test.gd"

var UsernameMenu = load("res://Scenes/username_menu.tscn")
var _menu = null

func before_each():
	_menu = UsernameMenu.instantiate()
	add_child(_menu)

func after_each():
	_menu.queue_free()
	
func test_next_button_exists():
	var button = _menu.get_node("NextButton")
	assert_not_null(button, "next button should exist")
	assert_connected(button, _menu, "pressed", "_on_next_button_pressed")
		
func test_on_next_button_pressed_logic():
	_menu._on_next_button_pressed()
	pass_test("test passed") # test passes if this line is reached
	
