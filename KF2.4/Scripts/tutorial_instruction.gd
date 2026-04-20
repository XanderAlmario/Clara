extends Panel

var instructionNumber = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$".".visible = true
	instructionNumber = 1

func instructionShow() -> void:
	instructionNumber += 1
	if instructionNumber == 2:
		$First.visible = false
		$Second.visible = true
	elif instructionNumber == 3:
		$Second.visible = false
		$Third.visible = true
	elif instructionNumber == 4:
		$Third.visible = false
		$Fourth.visible = true
	elif instructionNumber == 5:
		$Fourth.visible = false
		$Fifth.visible = true
	elif instructionNumber == 6:
		$Fifth.visible = false
		$Sixth.visible = true
	elif instructionNumber == 7:
		$Sixth.visible = false
		$Seventh.visible = true
	elif instructionNumber == 8:
		$Seventh.visible = false
		$Eighth.visible = true
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
