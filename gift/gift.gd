extends Area2D

func collected(_body: PhysicsBody2D) -> void:
	Settings.gifts += 1
	queue_free()
