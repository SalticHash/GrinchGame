extends Node
var level_seed = 10
var gifts: int = 0 :
	set(value):
		gifts = value
		UI.set_gifts(gifts)
var houses: int = 0 :
	set(value):
		houses = value
		UI.set_houses(houses)
