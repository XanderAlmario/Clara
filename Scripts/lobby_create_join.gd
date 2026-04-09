extends Control

var create_scene: PackedScene = preload("res://Scenes/create_lobby.tscn")
var join_scene: PackedScene = preload("res://Scenes/join_lobby.tscn")
var player
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_node("Player")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_create_button_pressed():
	var next_scene = create_scene.instantiate()
	player.reparent(next_scene)
	self.get_parent().add_child(next_scene)
	self.queue_free()
	#get_tree().change_scene_to_file("res://Scenes/create_lobby.tscn")


func _on_join_button_pressed() -> void:
	var next_scene = join_scene.instantiate()
	player.reparent(next_scene)
	self.get_parent().add_child(next_scene)
	self.queue_free()
	#get_tree().change_scene_to_file("res://Scenes/join_lobby.tscn")


func _on_back_pressed():
	get_tree().change_scene_to_file("res://Scenes/username_menu.tscn")
