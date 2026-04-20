extends Control

## DOCUMENTATION
# 
#  menu.gd is mainly for redirecting to
#  other scenes inside the Main Menu
#
#  Functions:
# 	func redirect(page : string) -> {}
#
##
signal host
signal join

var pages = {
	"Menu" = null,
	"Start" = null,
	"Profile" = null,
	"Lobby" = null,
	"MatchSummary" = null
}

var player

func redirect(page) -> void:
	for p in pages:
		if not p == page:
			if pages[p]:
				pages[p].visible = false
		else:
			pages[p].visible = true

func _ready() -> void:
	pages["Menu"] = $MenuPage
	pages["Start"] = $StartPage
	pages["Profile"] = $ProfilePage
	pages["Lobby"] = $LobbyPage
	pages["MatchSummary"] = $MatchSummaryPage
	
	player = $"../Player"

## MENU PAGE BUTTONS
func _on_start_button_pressed() -> void:
	redirect("Start")

func _on_settings_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Tutorial.tscn")

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_profile_button_pressed() -> void:
	redirect("Profile")

func _on_profile_button_mouse_entered() -> void:
	pages["Menu"].get_node("Profile").modulate = Color(0.5,0.5,0.5,1)

func _on_profile_button_mouse_exited() -> void:
	pages["Menu"].get_node("Profile").modulate = Color(1,1,1,1)

## START PAGE BUTTONS
func _on_start_back_button_pressed() -> void:
	redirect("Menu")
	
func _on_host_button_pressed() -> void:
	emit_signal("host")
	
func _on_join_button_pressed() -> void:
	emit_signal("join")

## SETTINGS PAGE BUTTONS
func _on_settings_back_button_pressed() -> void:
	redirect("Menu")
	
## MATCH SUMMARY PAGE BUTTONS
func _on_to_menu_button_pressed() -> void:
	redirect("Menu")
