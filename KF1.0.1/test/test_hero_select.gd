extends "res://addons/gut/test.gd"

var HeroMenu = load("res://Scenes/hero_select.tscn")
var _menu = null

func before_each():
	_menu = HeroMenu.instantiate()
	add_child(_menu)

func after_each():
	_menu.queue_free()
	
func test_mage_select_exists():
	var button = _menu.get_node("MageSelect")
	assert_not_null(button, "mage button should exist")
	assert_connected(button, _menu, "pressed", "_on_mage_select_pressed")
	
func test_monk_select_exists():
	var button = _menu.get_node("MonkSelect")
	assert_not_null(button, "monk button should exist")
	assert_connected(button, _menu, "pressed", "_on_monk_select_pressed")
	
func test_paladin_select_exists():
	var button = _menu.get_node("PaladinSelect")
	assert_not_null(button, "paladin button should exist")
	assert_connected(button, _menu, "pressed", "_on_paladin_select_pressed")
	
func test_undead_select_exists():
	var button = _menu.get_node("UndeadSelect")
	assert_not_null(button, "undead button should exist")
	assert_connected(button, _menu, "pressed", "_on_undead_select_pressed")
	
func test_archer_select_exists():
	var button = _menu.get_node("ArcherSelect")
	assert_not_null(button, "archer button should exist")
	assert_connected(button, _menu, "pressed", "_on_archer_select_pressed")
	
func test_on_mage_select_pressed_logic():
	_menu._on_mage_select_pressed()
	pass_test("test passed") # test passes if this line is reached
	
func test_on_monk_select_pressed_logic():
	_menu._on_monk_select_pressed()
	pass_test("test passed") # test passes if this line is reached
	
func test_on_paladin_select_pressed_logic():
	_menu._on_paladin_select_pressed()
	pass_test("test passed") # test passes if this line is reached
	
func test_on_undead_select_pressed_logic():
	_menu._on_undead_select_pressed()
	pass_test("test passed") # test passes if this line is reached
	
func test_on_archer_select_pressed_logic():
	_menu._on_archer_select_pressed()
	pass_test("test passed") # test passes if this line is reached
	
