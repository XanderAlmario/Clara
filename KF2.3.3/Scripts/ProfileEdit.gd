extends Control

var menu
var player
var line_edit
var confirm_button

func _ready() -> void:
	menu = get_parent()
	player = $"../../Player"
	line_edit = get_node("Panel/LineEdit")
	confirm_button = get_node("Panel/ConfirmButton")
	
func _on_confirm_button_pressed() -> void:
	if line_edit.text == "":
		player.change_username("Player 1")
	else:
		player.change_username(line_edit.text)
	menu.get_node("MenuPage/Profile/UsernameLabel").text = player.username
	menu.redirect("Menu")
