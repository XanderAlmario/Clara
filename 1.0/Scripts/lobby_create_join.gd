extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_create_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/create_lobby.tscn")


func _on_join_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/join_lobby.tscn")


func _on_back_pressed():
	get_tree().change_scene_to_file("res://Scenes/username_menu.tscn")
