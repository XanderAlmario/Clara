extends "res://addons/gut/test.gd"

var HeroMenu = load("res://Scenes/hero_select.tscn")
var _menu = null

var player = _menu.get_node("Player")

func before_each():
	_menu = HeroMenu.instantiate()
	add_child(_menu)

func after_each():
	_menu.queue_free()
	
func test_mage_button_activates_deck_view():
	var view_button = _menu.get_node("MageView")
	var back_button = _menu.get_node("MageDeckPanel/MageBack")
	
	assert_not_null(view_button, "view button should exist")
	assert_not_null(back_button, "back button should exist")
	
	var deck_view = _menu.get_node("MageDeckPanel")
	assert_not_null(deck_view, "deck panel should exist")
	
	assert_false(deck_view.visible, "mage deck should not be visible")
	view_button.emit_signal("pressed")
	assert_true(deck_view.visible, "mage deck should be visible")
	back_button.emit_signal("pressed")
	assert_false(deck_view.visible, "mage deck should not be visible")
	
func test_monk_button_activates_deck_view():
	var view_button = _menu.get_node("MonkView")
	var back_button = _menu.get_node("MonkDeckPanel/MonkBack")
	
	assert_not_null(view_button, "view button should exist")
	assert_not_null(back_button, "back button should exist")
	
	var deck_view = _menu.get_node("MonkDeckPanel")
	assert_not_null(deck_view, "deck panel should exist")
	
	assert_false(deck_view.visible, "monk deck should not be visible") # checks if deck view is initially disabled
	view_button.emit_signal("pressed")
	assert_true(deck_view.visible, "monk deck should be visible")
	back_button.emit_signal("pressed")
	assert_false(deck_view.visible, "monk deck should not be visible")
	
func test_pal_button_activates_deck_view():
	var view_button = _menu.get_node("PalView")
	var back_button = _menu.get_node("PalDeckPanel/PalBack")
	
	assert_not_null(view_button, "view button should exist")
	assert_not_null(back_button, "back button should exist")
	
	var deck_view = _menu.get_node("PalDeckPanel")
	assert_not_null(deck_view, "deck panel should exist")
	
	assert_false(deck_view.visible, "pal deck should not be visible") # checks if deck view is initially disabled
	view_button.emit_signal("pressed")
	assert_true(deck_view.visible, "pal deck should be visible") # checks if button works by checking if panel shows when pressed
	back_button.emit_signal("pressed")
	assert_false(deck_view.visible, "pal deck should not be visible")
	
func test_nec_button_activates_deck_view():
	var view_button = _menu.get_node("NecView")
	var back_button = _menu.get_node("NecDeckPanel/NecBack")	
	assert_not_null(view_button, "view button should exist")
	assert_not_null(back_button, "back button should exist")
	
	var deck_view = _menu.get_node("NecDeckPanel")
	assert_not_null(deck_view, "deck panel should exist")
	
	assert_false(deck_view.visible, "nec deck should not be visible") # checks if deck view is initially disabled
	view_button.emit_signal("pressed")
	assert_true(deck_view.visible, "nec deck should be visible")
	back_button.emit_signal("pressed")
	assert_false(deck_view.visible, "nec deck should not be visible")
	
func test_arch_button_activates_deck_view():
	var view_button = _menu.get_node("ArchView")
	var back_button = _menu.get_node("ArchDeckPanel/ArchBack")	
	assert_not_null(view_button, "view button should exist")
	assert_not_null(back_button, "back button should exist")
	
	var deck_view = _menu.get_node("ArchDeckPanel")
	assert_not_null(deck_view, "deck panel should exist")
	
	assert_false(deck_view.visible, "arch deck should not be visible") # checks if deck view is initially disabled
	view_button.emit_signal("pressed")
	assert_true(deck_view.visible, "arch deck should be visible")
	back_button.emit_signal("pressed")
	assert_false(deck_view.visible, "arch deck should not be visible")
	
func test_on_mage_select_pressed_logic():
	_menu._on_mage_select_pressed()
	assert_eq("Mage", player.champion, "player class should be set to mage")
	
func test_on_monk_select_pressed_logic():
	_menu._on_monk_select_pressed()
	assert_eq("Monk", player.champion, "player class should be set to mage")
	
func test_on_paladin_select_pressed_logic():
	_menu._on_paladin_select_pressed()
	assert_eq("Pal", player.champion, "player class should be set to mage")
	
func test_on_undead_select_pressed_logic():
	_menu._on_undead_select_pressed()
	assert_eq("Nec", player.champion, "player class should be set to mage")
	
func test_on_archer_select_pressed_logic():
	_menu._on_archer_select_pressed()
	assert_eq("Arch", player.champion, "player class should be set to mage")
	
