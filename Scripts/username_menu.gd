extends Control

var lobby_scene: PackedScene = preload("res://Scenes/lobby_create_join.tscn")
var player
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_node("Player")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_next_button_pressed():
	var next_scene = lobby_scene.instantiate()
	player.reparent(next_scene)
	self.get_parent().add_child(next_scene)
	self.queue_free()
	#get_tree().change_scene_to_file("res://Scenes/lobby_create_join.tscn") # Replace with function body.


func _on_back_pressed():
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
