extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Grinch.exiting_house:
		Grinch.goto_exited_house()


func fall_on_void(_body: PhysicsBody2D) -> void:
	Grinch.fall()
