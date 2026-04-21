extends GutTest

var menu

func before_each():
	menu = preload("res://Scenes/Menu.tscn").instantiate()
	add_child(menu)
	
	menu.pages = {
		"Menu" = null,
		"Start" = null,
		"Profile" = null,
		"Lobby" = null,
		"MatchSummary" = null
	}

func after_each():
	menu.queue_free()

func test_init_pages():
	for p in menu.pages:
		assert_null(menu.pages[p], p + " should be null!")
		
func test_redirect():
	menu.pages = {
		"Menu" = menu.get_node("MenuPage"),
		"Start" = menu.get_node("StartPage"),
		"Profile" = menu.get_node("ProfilePage"),
		"Lobby" = menu.get_node("LobbyPage"),
		"MatchSummary" = menu.get_node("MatchSummaryPage")
	}
	
	for p in menu.pages:
		menu.redirect(p)
		assert_true(menu.pages[p].visible, p + " should be visible!")
