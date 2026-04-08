const CARDS = { #Cost(0), Attack(1), Health(2), 
				#Card Type(3), Card Ability(4),
				#Lunge(5), Fury(6), Holy Shield(7),
				#
	"Scout" : [1, 1, 1, 
	"Unit", "Lunge", 
	true, false, false],
	
	"Ravager" : [1, 3, 3, 
	"Unit", "Lunge", 
	false, true, false],
	
	"Priest" : [1, 2, 2, 
	"Unit", "Holy Shield", 
	false, false, true],
	
	"Knight" : [1, 2, 3, 
	"Unit", "Knight Ability", 
	false, false, false],
	
	"Archer" : [2, 1, 1, 
	"Unit", "Archer Ability", 
	false, false, false],
	
	"Demon" : [3, 5, 7, "Unit", 
	"Demon Ability", 
	false, false, false]
}
