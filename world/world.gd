extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	seed(Settings.level_seed)
	return
	var x = 0
	for i in range(100):
		var house_res: PackedScene = $HouseRes.get_resource(str(randi_range(1, 1)))
		var house: StaticBody2D = house_res.instantiate()
		house.house_number = i + 1
		house.house_id = randi()
		house.global_position = Vector2(x, 360)
		x += house.width + randf_range(-50, 300)
		$Houses.add_child(house)
	
	if Grinch.exiting_house:
		Grinch.goto_last_chimney()


func fall_on_void(_body: PhysicsBody2D) -> void:
	Grinch.fall()
