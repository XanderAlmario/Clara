extends LineEdit

var player

func _ready() -> void:
	player = get_node("../Player")
	
func _process(delta: float) -> void:
	pass

func _on_text_changed(new_text: String) -> void:
	player.change_username(new_text)
	
	
