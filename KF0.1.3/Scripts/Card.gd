extends Node2D

signal hovering
signal stoppedHovering

var posInHand
var cardType

func _ready():
	# all Cards need to be a parent of CardManager or else it will error
	get_parent().connectSignals(self)

func _process(delta):
	pass

func _on_area_2d_mouse_entered():
	emit_signal("hovering", self)

func _on_area_2d_mouse_exited():
	emit_signal("stoppedHovering", self)
