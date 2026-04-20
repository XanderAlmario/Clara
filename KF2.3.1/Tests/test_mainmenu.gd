extends "res://addons/gut/test.gd"

var MainMenu = load("res://Scenes/main_menu.tscn")
var _menu = null

func before_each():
	_menu = MainMenu.instantiate()
	add_child(_menu)

func after_each():
	_menu.queue_free()
	
func test_start_button_exists():
	var button = _menu.get_node("VBoxContainer/StartButton")
	assert_not_null(button, "start button should exist")
	assert_connected(button, _menu, "pressed", "_on_start_button_pressed")
	
func test_settings_button_exists():
	var button = _menu.get_node("VBoxContainer/SettingsButton")
	assert_not_null(button, "settings button should exist")
	assert_connected(button, _menu, "pressed", "_on_settings_button_pressed")
	
func test_quit_button_exists():
	var button = _menu.get_node("VBoxContainer/QuitButton")
	assert_not_null(button, "quit button should exist")
	assert_connected(button, _menu, "pressed", "_on_quit_button_pressed")
	
func test_on_start_button_pressed_logic():
	_menu._on_start_button_pressed()
	pass_test("test passed") # test passes if this line is reached
	
func test_on_settings_button_pressed_logic():
	_menu._on_settings_button_pressed()
	pass_test("test passed") # test passes if this line is reached
	
func test_on_quit_button_pressed_logic():
	_menu._on_quit_button_pressed()
	pass_test("test passed") # test passes if this line is reached
