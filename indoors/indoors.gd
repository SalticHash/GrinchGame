extends Node2D

func _ready() -> void:
	if Grinch.entering_house:
		Grinch.goto_entered_house()
	for deleted_node_name in Settings.deleted_node_names:
		get_node(deleted_node_name).queue_free()
