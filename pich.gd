extends Area2D

var speed = 290
var damage = 15

func _physics_process(delta):
	position.x -= speed * delta

	if position.x < -1000:
		queue_free()

func _on_body_entered(body):

	if body.is_in_group("player"):
		body.take_damage(5, self)

		queue_free()
