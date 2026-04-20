extends Node2D

signal hovering
signal stoppedHovering

var posInHand
var posInBF
var cardType
var cardSlot
var cardName
var cost
var attack
var health
var dead = false
var canAttack = true
var firstAttack = false
var flipped = false

var lunge
var fury
var holyShield
var lifeDrain
var fastHands
var momentum
var bodyguard
var holyBlessing
var reincarnate
var evasive

var spellScript

func _ready():
	# all Cards need to be a parent of CardManager or else it will error
	if get_parent().has_method("connectSignals"):
		get_parent().connectSignals(self)

func _process(delta):
	pass

func _on_area_2d_mouse_entered():
	emit_signal("hovering", self)

func _on_area_2d_mouse_exited():
	emit_signal("stoppedHovering", self)
