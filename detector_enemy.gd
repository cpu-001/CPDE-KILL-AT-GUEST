extends Area2D

@onready var player = get_parent()

func _on_body_entered(body):
	print("TOCÓ:", body.name)

	if body.is_in_group("enemy"):
		print("DAMAGE APLICADO")

		get_parent().take_damage(20, body.global_position)
		body.queue_free()
