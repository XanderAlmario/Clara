extends GutTest

var main

func before_each():
	main = preload("res://Scripts/main.gd").new()
	
	main = preload("res://Scenes/Main.tscn").instantiate()
	main.menu = main.get_node("Menu")
	main.player = main.get_node("Player")
	main.opponent = main.get_node("Opponent")
	
	add_child(main)

func after_each():
	main.queue_free()

func test_hosting_sets_host_and_redirects():
	main.hosting()
	
	assert_true(main.host)
	assert_true(main.menu.get_node("LobbyPage").visible)
	
func test_joining_sets_client_mode():
	main.joining()
	
	assert_false(main.host)
	assert_true(main.menu.get_node("LobbyPage").visible)
	
func test_game_ended_win_sets_text_and_redirects():
	var label = main.menu.get_node("MatchSummaryPage/Panel/ResultLabel")
	
	main.menu.redirect("Menu")
	main.menu.visible = false
	
	main.game_ended(true)
	
	var result = label.text
	
	assert_eq(result, "YOU WIN!")
	#assert_true(main.menu.get_node("MatchSummaryPage").visible)
	#assert_true(main.menu.visible)
	
func test_game_ended_lose_sets_text_and_redirects():
	var label = main.menu.get_node("MatchSummaryPage/Panel/ResultLabel")
	
	main.menu.redirect("Menu")
	main.menu.visible = false
	
	main.game_ended(false)
	
	assert_eq(label.text, "YOU LOSE!")
	#assert_true(main.menu.get_node("MatchSummaryPage").visible)
	#assert_true(main.menu.visible)
