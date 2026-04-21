extends GutTest

var main

func before_each():
	var scene = load("res://Scenes/Menu.tscn")
	main = scene.instantiate()
	add_child(main)
	main.menu = main.get_node("Menu")
	await get_tree().process_frame

func after_each():
	main.queue_free()

#func test_line_edit():
	#menu.get_node("ProfilePage/Panel/LineEdit").text = "test1"
	#assert_eq(menu.get_node("ProfilePage/Panel/LineEdit").text, "test1", "Profile's LineEdit is not working.")
#
#func test_confirm_button():
	#menu.get_node("ProfilePage/Panel/LineEdit").text = "test2"
	#
	#menu._on_confirm_button_pressed()
	#assert_eq(menu.Player.username, "test2", "Player username not updated")
