extends Node2D

@onready var GIFT_SCENE = preload("res://gift/gift.tscn")
func _ready() -> void:
	seed(Grinch.house)
	for i in range(100):
		var gift = GIFT_SCENE.instantiate()
		gift.global_position = Vector2(
			randf_range(0, 640),
			randf_range(0, 360),
		)
		$Gifts.add_child(gift)
