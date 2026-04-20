extends GutTest

var menu

func before_each():
	var scene = load("res://Scenes/Menu.tscn")
	menu = scene.instantiate()
	add_child(menu)
	await get_tree().process_frame

func after_each():
	menu.queue_free()

func test_redirect_to_match_summary():
	menu.redirect("MatchSummary")
	assert_true(menu.get_node("MatchSummaryPage").visible, "Match Summary should be visible")

func test_back_to_menu_from_match_summary():
	menu._on_to_menu_button_pressed()
	assert_true(menu.get_node("MenuPage").visible, "Menu should be visible")
