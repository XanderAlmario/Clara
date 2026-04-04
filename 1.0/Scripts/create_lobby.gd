extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/hero_select.tscn")



func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/lobby_create_join.tscn")
