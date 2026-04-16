extends "res://addons/gut/test.gd"

var summary = load("res://Scenes/match_summary.tscn")
var _menu = null

func before_each():
	_menu = summary.instantiate()
	add_child(_menu)

func after_each():
	_menu.queue_free()
	
func test_back_exists():
	var button = _menu.get_node("BackButton")
	assert_not_null(button, "back button should exist")
	assert_connected(button, _menu, "pressed", "_on_back_pressed")
	
func test_on_back_pressed_logic():
	_menu._on_back_pressed()
	pass_test("test passed") # test passes if this line is reached
	
