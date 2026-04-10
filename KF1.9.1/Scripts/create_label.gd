extends Label

var player
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_node("../Player")
	self.text = "%s's Room" % player.username

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
