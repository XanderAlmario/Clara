extends Control

var select_scene: PackedScene = preload("res://Scenes/hero_select.tscn")
var player
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_node("Player")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_button_pressed():
	var next_scene = select_scene.instantiate()
	var next_scene_player = next_scene.get_node("Player")
	next_scene_player.change_username(player.username)
	next_scene_player.choose_champion(player.champion)
	self.get_parent().add_child(next_scene)
	self.queue_free()



func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/lobby_create_join.tscn")
