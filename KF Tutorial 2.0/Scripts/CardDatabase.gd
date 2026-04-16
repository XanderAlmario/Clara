#Enemy AI Card Database
const CARDS = { #Cost(0), Attack(1), Health(2), 
				#Card Type(3), Card Ability(4),
				#Lunge(5), Fury(6), Holy Shield(7),
				#Life Drain(8), Momentum(9), Fast Hands(10)
				#Ability Script(11)
		"Training Student" : [1, 1, 1,
	"Unit", "Momentum",
	false, false, false,
	false, false, false],
	
	"Aspirant Squire" : [1, 1, 1,
	"Unit", "Bodyguard",
	false, false, false,
	false, false, false],
	
	"Blessed Parishioner" : [2, 2, 2, 
	"Unit", "Lunge", 
	false, false, false,
	false, false, false],
	
	"Thaloran Lightguard" : [8, 3, 3, 
	"Unit", "Lunge", 
	false, false, false,
	false, false, false],
	
	"Summon the Infantry" : [6, null, null, 
	"Spell", "Holy Shield", 
	false, false, false,
	false, false, false, 
	"res://Scripts/Abilities/Discovery.gd"],
	
	"Artimose Aetheron" : [5, 2, 2, 
	"Unit", "Bloated", 
	false, false, false,
	false, true, false],
	
	"Defender Aura" : [5, 2, 3, 
	"Unit", "Knight Ability", 
	false, false, false,
	false, false, false],
	
	"Holy Crusader" : [4, 2, 3, 
	"Unit", "Knight Ability", 
	false, false, false,
	false, false, false],
	
	"Blessed Crusader Hound" : [3, 1, 1, 
	"Unit", "Archer Ability", 
	false, false, false,
	false, false, false],
	
	"Way of Astral Master" : [8, 5, 7, "Unit", 
	"Demon Ability", 
	false, false, false,
	false, false, false],
	
	"Kensei Monk" : [6, 5, 7, "Unit", 
	"Demon Ability", 
	false, false, false,
	false, false, false],
	
	"Way of Mercy Master" : [6, 5, 7, "Unit", 
	"Demon Ability", 
	false, false, false,
	false, false, false],
	
	"Swiftfist Monk" : [5, 5, 7, "Unit", 
	"Demon Ability", 
	false, false, false,
	false, false, false],
	
	"Astral Projection" : [5, null, null, 
	"Spell", "Draw Cards", 
	false, false, false, 
	false, false, false, 
	"res://Scripts/Abilities/Discovery.gd"],
	
	"Shadow Arts" : [3, null, null, 
	"Spell", "Deal 2 Damage to a random enemy", 
	false, false, false, 
	false, false, false,
	"res://Scripts/Abilities/FrozenSpike.gd"],
}
