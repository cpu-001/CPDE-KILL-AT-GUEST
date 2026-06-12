extends Area2D

var velocity = Vector2.ZERO

@export var score_value: int = 1

func _physics_process(delta):
	position += velocity * delta

func set_velocity(new_velocity: Vector2):
	velocity = new_velocity

func _ready():
	add_to_group("projectiles")

func _on_body_entered(body):
	if body.is_in_group("enemy"):
		if body.has_method("die"):
			body.die()

		Gamedata.add_kill(10)
		queue_free()

	print("Hit detectado en peer:", multiplayer.get_unique_id())
