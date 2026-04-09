extends LineEdit

var player
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_node("../Player")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_text_changed(new_text: String) -> void:
	player.change_username(new_text)
