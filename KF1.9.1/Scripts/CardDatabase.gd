const CARDS = { #Cost(0), Attack(1), Health(2), 
				#Card Type(3), Card Ability(4),
				#Lunge(5), Fury(6), Holy Shield(7),
				#Life Drain(8), Bloated(9), Ability Script(10)
	"Scout" : [1, 1, 1, 
	"Unit", "Lunge", 
	true, false, false,
	false, false],
	
	"Ravager" : [1, 3, 3, 
	"Unit", "Lunge", 
	false, true, false,
	false, false],
	
	"Priest" : [1, 2, 2, 
	"Unit", "Holy Shield", 
	false, false, true,
	false, false],
	
	"Leech" : [1, 2, 2, 
	"Unit", "Life Drain", 
	false, false, false,
	true, false],
	
	"Kamikaze" : [1, 2, 2, 
	"Unit", "Bloated", 
	false, false, false,
	false, true],
	
	"Knight" : [1, 2, 3, 
	"Unit", "Knight Ability", 
	false, false, false,
	false, false],
	
	"Archer" : [2, 1, 1, 
	"Unit", "Archer Ability", 
	false, false, false,
	false, false],
	
	"Demon" : [3, 5, 7, "Unit", 
	"Demon Ability", 
	false, false, false,
	false, false],
	
	"Discovery" : [2, null, null, 
	"Spell", "Draw Cards", 
	false, false, false, 
	false, false,
	"res://Scripts/Abilities/Discovery.gd"],
	
	"Frozen Spike" : [2, null, null, 
	"Spell", "Deal 2 Damage to a random enemy", 
	false, false, false, 
	false, false,
	"res://Scripts/Abilities/FrozenSpike.gd"],
}
