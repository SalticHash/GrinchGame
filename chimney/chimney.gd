extends Area2D

@onready var world = get_parent().get_parent()

func player_entered(_body: Node2D) -> void:
	var world_bg = world.get_node("ParallaxBackground")
	world_bg.hide()
	var player_camera: Camera2D = Grinch.get_node("Camera")
	Grinch.get_node("AnimationPlayer").play("enter_house")

	player_camera.limit_bottom = 1000
	player_camera.limit_top = -1000
