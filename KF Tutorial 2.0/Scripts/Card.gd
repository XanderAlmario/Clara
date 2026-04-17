extends Node2D

signal hovering
signal stoppedHovering

var posInHand
var posInBF
var cardType
var cardSlot
var cost
var attack
var health
var dead = false
var canAttack = false
var firstAttack = false

var lunge
var fury
var holyShield
var lifeDrain
var momentum
var fastHands

var spellScript

func _ready():
	# all Cards need to be a parent of CardManager or else it will error
	get_parent().connectSignals(self)

func _process(delta):
	pass

func _on_area_2d_mouse_entered():
	emit_signal("hovering", self)

func _on_area_2d_mouse_exited():
	emit_signal("stoppedHovering", self)
