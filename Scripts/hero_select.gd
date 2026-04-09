extends Control

var main_scene: PackedScene = preload("res://Scenes/Main.tscn")
var player
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_node("Player")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_mage_select_pressed() -> void:
	player.choose_champion("Mage")
	var next_scene = main_scene.instantiate()
	player.reparent(next_scene)
	self.get_parent().add_child(next_scene)
	self.queue_free()
	#get_tree().change_scene_to_file("res://Scenes/Main.tscn")


func _on_monk_select_pressed() -> void:
	player.choose_champion("Monk")
	var next_scene = main_scene.instantiate()
	player.reparent(next_scene)
	self.get_parent().add_child(next_scene)
	self.queue_free()
	#get_tree().change_scene_to_file("res://Scenes/Main.tscn")


func _on_paladin_select_pressed() -> void:
	player.choose_champion("Paladin")
	var next_scene = main_scene.instantiate()
	player.reparent(next_scene)
	self.get_parent().add_child(next_scene)
	self.queue_free()
	#get_tree().change_scene_to_file("res://Scenes/Main.tscn")


func _on_undead_select_pressed() -> void:
	player.choose_champion("Undead")
	var next_scene = main_scene.instantiate()
	player.reparent(next_scene)
	self.get_parent().add_child(next_scene)
	self.queue_free()
	#get_tree().change_scene_to_file("res://Scenes/Main.tscn")


func _on_archer_select_pressed() -> void:
	player.choose_champion("Archer")
	var next_scene = main_scene.instantiate()
	player.reparent(next_scene)
	self.get_parent().add_child(next_scene)
	self.queue_free()
	#get_tree().change_scene_to_file("res://Scenes/Main.tscn")


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/create_lobby.tscn")
