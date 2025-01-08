extends CanvasLayer

func change_scene(scene, animation: String = "tdot") -> void:
	$AnimationPlayer.play(animation + "_close")
	await $AnimationPlayer.animation_finished
	if typeof(scene) == TYPE_STRING:
		get_tree().change_scene_to_file(scene)
	elif scene is PackedScene:
		get_tree().change_scene_to_packed(scene)
		
	$AnimationPlayer.play(animation + "_open")
