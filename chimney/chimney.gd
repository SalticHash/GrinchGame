extends Area2D

@onready var world = get_parent().get_parent()

func player_entered(_body: Node2D) -> void:
	if Grinch.current_house_id == "NONE":
		Grinch.enter_house(name)
	else:
		Grinch.exit_house()
