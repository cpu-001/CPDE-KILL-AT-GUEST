extends CharacterBody2D

@export var wait_time := 3.0
@export var dash_speed := 2500.0
@export var damage := 35

var player = null
var charging := false
var exploded := false

@export var death_particles_scene: PackedScene

func _ready():

	player = get_tree().get_first_node_in_group("player")

	await get_tree().create_timer(wait_time).timeout

	if player == null:
		queue_free()
		return

	charging = true


func _physics_process(delta):

	if exploded:
		return

	if not charging:
		return

	if player == null:
		return

	var dir = (player.global_position - global_position).normalized()

	velocity = dir * dash_speed

	move_and_slide()


func _on_area_2d_body_entered(body):

	if exploded:
		return

	if body.is_in_group("player"):

		if body.has_method("take_damage"):
			body.take_damage(damage, self)

		die()


func die():

	if exploded:
		return

	exploded = true

	spawn_death_effect()

	queue_free()


func spawn_death_effect():
	if death_particles_scene == null:
		return

	var fx = death_particles_scene.instantiate()

	get_tree().current_scene.add_child(fx)

	# 🔥 CLAVE ABSOLUTA
	fx.global_position = global_position
