extends Area2D

@export var next_level := 2

func _on_body_entered(body):

	if body.is_in_group("player"):

		if body.has_key:
			Gamedata.level = next_level
			get_tree().change_scene_to_file("res://test.tscn")
