extends "res://addons/gut/test.gd"

var Match = load("res://Scenes/Main.tscn")
var _menu = null

func before_each():
	_menu = Match.instantiate()
	add_child(_menu)

func after_each():
	_menu.queue_free()
	
func test_match_button_exists():
	var button = _menu.get_node("MatchButton")
	assert_not_null(button, "match button should exist")
	assert_connected(button, _menu, "pressed", "_on_match_button_pressed")
	
func test_on_match_button_pressed_logic():
	_menu._on_match_button_pressed()
	pass_test("test passed") # test passes if this line is reached
	
