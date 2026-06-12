extends Area2D

@onready var label = $CanvasLayer/press

var player_in_range := false

func _on_body_entered(body):

	if body.is_in_group("player"):
		player_in_range = true
		label.visible = player_in_range


func _on_body_exited(body):

	if body.is_in_group("player"):
		player_in_range = false
		label.visible = player_in_range


func _process(_delta):

	if player_in_range and Input.is_action_just_pressed("interact"):

		var player = get_tree().get_first_node_in_group("player")

		if player:
			player.has_key = true

		queue_free()
