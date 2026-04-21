extends GutTest

 
var panel : Node2D
 
func before_each():
	panel = preload("res://Scenes/Tutorial.tscn").instantiate()
	add_child_autofree(panel)
	await get_tree().process_frame 
 
func _advance(times: int):
	for _i in range(times):
		panel.get_node("TutorialInstruction").instructionShow()

# uses instructionShow() function in tutorial_instruction.gd to open next instruction
# and hide the previous one
 

# first test, check if panel itself is visible
# then checks if first instructions is visible
 
func test_panel_visible_on_ready():
	assert_true(panel.visible, "Panel itself should be visible on ready")
 
func test_first_visible_on_ready():
	assert_true(panel.get_node("TutorialInstruction/First").visible,  "First should be visible on ready")
 
func test_second_hidden_on_ready():
	assert_false(panel.get_node("TutorialInstruction/Second").visible, "Second should be hidden on ready")
 
# second test, checks if second instruction is visible
# checks if first instruction is invisible
 
func test_step2_shows_second():
	_advance(1)
	assert_true(panel.get_node("TutorialInstruction/Second").visible, "Second should be visible at step 2")
 
func test_step2_hides_first():
	_advance(1)
	assert_false(panel.get_node("TutorialInstruction/First").visible, "First should be hidden at step 2")
 
# third test, checks if third instruction is visible
# checks if second instruction is invisible
 
func test_step3_shows_third():
	_advance(2)
	assert_true(panel.get_node("TutorialInstruction/Third").visible)
 
func test_step3_hides_second():
	_advance(2)
	assert_false(panel.get_node("TutorialInstruction/Second").visible)
 
# fourth test, checks if fourth instruction is visible
# checks if third instruction is invisible

func test_step4_shows_fourth():
	_advance(3)
	assert_true(panel.get_node("TutorialInstruction/Fourth").visible)
 
func test_step4_hides_third():
	_advance(3)
	assert_false(panel.get_node("TutorialInstruction/Third").visible)

# fifth test, checks if fifth instruction is visible
# checks if fourth instruction is invisible
 
func test_step5_shows_fifth():
	_advance(4)
	assert_true(panel.get_node("TutorialInstruction/Fifth").visible)
 
func test_step5_hides_fourth():
	_advance(4)
	assert_false(panel.get_node("TutorialInstruction/Fourth").visible)
 
# sixth test, checks if sixth instruction is visible
# checks if fifth instruction is invisible
 
func test_step6_shows_sixth():
	_advance(5)
	assert_true(panel.get_node("TutorialInstruction/Sixth").visible)
 
func test_step6_hides_fifth():
	_advance(5)
	assert_false(panel.get_node("TutorialInstruction/Fifth").visible)
 
# seventh test, checks if seventh instruction is visible
# checks if sixth instruction is invisible
 
func test_step7_shows_seventh():
	_advance(6)
	assert_true(panel.get_node("TutorialInstruction/Seventh").visible)
 
func test_step7_hides_sixth():
	_advance(6)
	assert_false(panel.get_node("TutorialInstruction/Sixth").visible)
 
# eighth test, checks if eighth instruction is visible
# checks if seventh instruction is invisible
 
func test_step8_shows_eighth():
	_advance(7)
	assert_true(panel.get_node("TutorialInstruction/Eighth").visible)
 
func test_step8_hides_seventh():
	_advance(7)
	assert_false(panel.get_node("TutorialInstruction/Seventh").visible)
