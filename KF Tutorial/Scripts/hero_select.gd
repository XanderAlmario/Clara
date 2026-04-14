extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_mage_select_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Main.tscn")


func _on_monk_select_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Main.tscn")


func _on_paladin_select_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Main.tscn")


func _on_undead_select_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Main.tscn")


func _on_archer_select_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Main.tscn")


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/create_lobby.tscn")
