extends Node

var username
var champion
var deck

func _ready() -> void:
	username = "Default"
	
func change_username(new_username) -> void:
	username = new_username

func choose_champion(chosen_champion) -> void:
	champion = chosen_champion
	
