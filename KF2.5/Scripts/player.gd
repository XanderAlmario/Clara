extends Node

var username
var champion
# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	username = "Player 1"
	champion = ""

func change_username(new_username) -> void:
	username = new_username

func choose_champion(chosen_champion) -> void:
	champion = chosen_champion
