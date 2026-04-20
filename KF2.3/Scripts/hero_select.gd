extends Control
@onready var mage_frame = $"MageDeckPanel"
@onready var monk_frame = $"MonkDeckPanel"
@onready var pal_frame = $"PalDeckPanel"
@onready var nec_frame = $"NecDeckPanel"
@onready var arch_frame = $"ArchDeckPanel"

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
	var next_scene_player = next_scene.get_node("Player")
	next_scene_player.change_username(player.username)
	next_scene_player.choose_champion(player.champion)
	self.get_parent().add_child(next_scene)
	self.queue_free()
	#get_tree().change_scene_to_file("res://Scenes/Main.tscn")


func _on_monk_select_pressed() -> void:
	player.choose_champion("Monk")
	var next_scene = main_scene.instantiate()
	var next_scene_player = next_scene.get_node("Player")
	next_scene_player.change_username(player.username)
	next_scene_player.choose_champion(player.champion)
	self.get_parent().add_child(next_scene)
	self.queue_free()
	#get_tree().change_scene_to_file("res://Scenes/Main.tscn")


func _on_paladin_select_pressed() -> void:
	player.choose_champion("Paladin")
	var next_scene = main_scene.instantiate()
	var next_scene_player = next_scene.get_node("Player")
	next_scene_player.change_username(player.username)
	next_scene_player.choose_champion(player.champion)
	self.get_parent().add_child(next_scene)
	self.queue_free()
	#get_tree().change_scene_to_file("res://Scenes/Main.tscn")


func _on_undead_select_pressed() -> void:
	player.choose_champion("Undead")
	var next_scene = main_scene.instantiate()
	var next_scene_player = next_scene.get_node("Player")
	next_scene_player.change_username(player.username)
	next_scene_player.choose_champion(player.champion)
	self.get_parent().add_child(next_scene)
	self.queue_free()
	#get_tree().change_scene_to_file("res://Scenes/Main.tscn")


func _on_archer_select_pressed() -> void:
	player.choose_champion("Archer")
	var next_scene = main_scene.instantiate()
	var next_scene_player = next_scene.get_node("Player")
	next_scene_player.change_username(player.username)
	next_scene_player.choose_champion(player.champion)
	self.get_parent().add_child(next_scene)
	self.queue_free()
	#get_tree().change_scene_to_file("res://Scenes/Main.tscn")


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/create_lobby.tscn")


func _on_mage_view_pressed() -> void:
	mage_frame.visible = true


func _on_monk_view_pressed() -> void:
	monk_frame.visible = true


func _on_pal_view_pressed() -> void:
	pal_frame.visible = true


func _on_nec_view_pressed() -> void:
	nec_frame.visible = true


func _on_arch_view_pressed() -> void:
	arch_frame.visible = true


func _on_mage_hide_button_pressed() -> void:
	mage_frame.visible = false


func _on_monk_hide_button_pressed() -> void:
	monk_frame.visible = false


func _on_pal_hide_button_pressed() -> void:
	pal_frame.visible = false


func _on_nec_hide_button_pressed() -> void:
	nec_frame.visible = false


func _on_arch_hide_button_pressed() -> void:
	arch_frame.visible = false
